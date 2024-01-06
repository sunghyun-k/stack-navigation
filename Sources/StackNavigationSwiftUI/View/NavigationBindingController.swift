import SwiftUI
import UIKit
import Combine
@_spi(package) import enum StackNavigation.NavigationUpdateContext

open class NavigationBindingController<Content>:
  UIHostingController<_NavigationEnvironmentView<Content>>
  where Content: View
{
  
  public init(content: Content) {
    super.init(rootView: _NavigationEnvironmentView { content })
    
    attachEnvironment()
  }
  
  public required init?(coder aDecoder: NSCoder) { fatalError() }
  
  private let onChildDismissPublisher = PassthroughSubject<Void, Never>()
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !isMovingToParent {
      onChildDismissPublisher.send()
    }
  }
  
  public func updateView(_ content: Content) {
    rootView.content = content
  }
  
  private func attachEnvironment() {
    rootView.onTitleChanged = { [weak self] title in
      self?.title = title
    }
    rootView.onNavigationBarHiddenChanged = { [weak self] hidden in
      self?.navigationController?.isNavigationBarHidden = hidden
    }
    rootView.navigationControllerProxy = .init(
      pushViewController: { [weak self] vc in
        self?.pushFromSelf(vc)
      },
      
      popToSelf: { [weak self] in
        self?.popToSelf()
      },
      
      onChildDismissStream: { [weak self] in
        AsyncStream { [weak self] continuation in
          let sub = self?.onChildDismissPublisher
            .sink { continuation.yield() }
          continuation.onTermination = { _ in
            sub?.cancel()
          }
        }
      }
    )
    rootView.dismiss = { [weak self] in
      guard
        let nc = self?.navigationController,
        let selfPosition = nc.viewControllers
          .lastIndex(where: { $0 === self }),
        selfPosition >= 0
      else { return }
      nc.popToViewController(
        nc.viewControllers[selfPosition - 1],
        animated: true
      )
    }
  }
  
  private func pushFromSelf(_ viewController: UIViewController) {
    guard
      let oldVCs = navigationController?.viewControllers,
      let selfPosition = oldVCs.lastIndex(where: { $0 === self })
    else { return }
    let newVCs: [UIViewController] = oldVCs.prefix(selfPosition + 1) + [viewController]
    withoutPublishChanges {
      navigationController?.setViewControllers(newVCs, animated: true)
    }
  }
  
  private func popToSelf() {
    if navigationController?.topViewController !== self {
      withoutPublishChanges {
        navigationController?.popToViewController(self, animated: true)
      }
    }
  }
  
  private func withoutPublishChanges(action: @MainActor () -> Void) {
    NavigationUpdateContext.$isUpdatingView.withValue(true) {
      action()
    }
  }
}

public struct _NavigationEnvironmentView<Content: View>: View {
  
  var onTitleChanged: @MainActor (String) -> Void = { _ in }
  var onNavigationBarHiddenChanged: (Bool) -> Void = { _ in }
  var navigationControllerProxy = NavigationControllerProxy.defaultValue
  var dismiss: (@MainActor () -> Void)?
  @ViewBuilder
  var content: Content
  
  public var body: some View {
    content
      .onPreferenceChange(NavigationTitlePreferenceKey.self) { newValue in
        onTitleChanged(newValue)
      }
      .onPreferenceChange(NavigationBarHiddenKey.self) { newValue in
        onNavigationBarHiddenChanged(newValue)
      }
      .environment(\.snDismiss, .init(action: { dismiss?() }))
      .environment(
        \.navigationController,
        navigationControllerProxy
      )
  }
}
