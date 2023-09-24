import UIKit
import SwiftUI

open class StackNavigationController<Data>: UINavigationController
  where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
        Data.Element: Hashable
{
  
  private var lastPath: Data
  public var onPathChanged: ((Data) -> Void)?
  private func publishPath() {
    if !NavigationUpdateContext.isUpdatingView {
      onPathChanged?(lastPath)
    }
  }
  
  private var dataPositions: [ObjectIdentifier: Data.Index] = [:]
  private func setPosition(_ position: Data.Index, for viewController: UIViewController) {
    dataPositions[ObjectIdentifier(viewController)] = position
  }
  private func removePathElement(for viewController: UIViewController) {
    let key = ObjectIdentifier(viewController)
    guard let position = dataPositions[key] else { return }
    dataPositions[key] = nil
    lastPath.remove(at: position)
  }
  
  public var destinations = DestinationBuilderStorage()
  
  public init(
    rootViewController: UIViewController,
    initialPath: Data,
    onPathChanged: ((Data) -> Void)? = nil,
    destinations: DestinationBuilderStorage = DestinationBuilderStorage()
  ) {
    self.destinations = destinations
    self.onPathChanged = onPathChanged
    self.lastPath = initialPath
    
    super.init(rootViewController: rootViewController)
  }
  
  public convenience init(
    rootViewController: UIViewController,
    initialPath: Data,
    onPathChanged: ((Data) -> Void)? = nil,
    destination: @escaping (Data.Element) -> UIViewController
  ) {
    var destinations = DestinationBuilderStorage()
    destinations[Data.Element.self] = .init(
      makeViewController: { destination($0) },
      updateViewController: { _, _ in }
    )
    self.init(
      rootViewController: rootViewController,
      initialPath: initialPath,
      onPathChanged: onPathChanged,
      destinations: destinations
    )
  }
  
  public required init?(coder aDecoder: NSCoder) { fatalError() }
  
  open func updateStacks(_ path: Data) {
    if lastPath.elementsEqual(path) {
      updateChildViews()
      return
    }
    guard let rootVC = viewControllers.first else { return }
    lastPath = path
    // 루트VC는 건너뛰고 업데이트한다.
    let oldVCsCount = viewControllers.count - 1
    
    let oldVCs = path.count > oldVCsCount
      ? Array(viewControllers.dropFirst()) + [UIViewController?](
        repeating: nil, count: path.count - oldVCsCount)
      : Array(viewControllers.dropFirst().prefix(path.count))
    
    dataPositions = [:]
    var newVCs: [UIViewController] = []
    for (index, vc) in zip(path.indices, oldVCs) {
      let datum = path[index]
      guard let builder = destinations[datum: datum] else {
        newVCs.append(UIHostingController(rootView: Text("⚠️")))
        return
      }
      if let vc, builder.updateViewController(vc, datum) {
        newVCs.append(vc)
      } else {
        let vc = builder.makeViewController(datum)
        _ = builder.updateViewController(vc, datum)
        newVCs.append(vc)
      }
      setPosition(index, for: newVCs.last!)
    }
    super.setViewControllers([rootVC] + newVCs, animated: true)
  }
  
  private func updateChildViews() {
    for (datum, vc) in zip(lastPath, viewControllers.dropFirst()) {
      if let builder = destinations[datum: datum] {
        _ = builder.updateViewController(vc, datum)
      }
    }
  }
  
  open override func popViewController(animated: Bool) -> UIViewController? {
    guard let poppedVC = super.popViewController(animated: animated) else { return nil }
    // 팝 제스쳐가 끝나고 업데이트 하기 위한 분기.
    if animated, let transitionCoordinator {
      transitionCoordinator.animate(alongsideTransition: nil) { [weak self] context in
        if context.isCancelled { return }
        self?.removePathElement(for: poppedVC)
        self?.publishPath()
      }
      
    } else {
      removePathElement(for: poppedVC)
      publishPath()
    }
    return poppedVC
  }
  
  open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
    guard let poppedVCs = super.popToViewController(viewController, animated: animated) else { return nil }
    // reversed: O(1)
    for poppedVC in poppedVCs.reversed() {
      removePathElement(for: poppedVC)
    }
    publishPath()
    return poppedVCs
  }
  
  open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    let poppedVCs = super.popToRootViewController(animated: animated)
    lastPath.removeAll(keepingCapacity: false)
    publishPath()
    return poppedVCs
  }
  
  open override func setViewControllers(_ newViewControllers: [UIViewController], animated: Bool) {
    let oldVCs = Set(viewControllers.dropFirst())
    let newVCs = Set(newViewControllers.dropFirst())
    let poppedVCs = oldVCs.subtracting(newVCs)
    super.setViewControllers(newViewControllers, animated: animated)
    // reversed: O(n)
    for poppedVC in poppedVCs.reversed() {
      removePathElement(for: poppedVC)
    }
    publishPath()
  }
  
}
