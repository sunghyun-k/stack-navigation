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
    rootView.navigationControllerProxy = .init(
      pushViewController: { [weak self] vc in
        self?.pushFromSelf(vc)
      },
      
      popToSelf: { [weak self] in
        self?.popToSelf()
      },
      
      onDismissStream: { [weak self] in
        AsyncStream { [weak self] continuation in
          let sub = self?.onChildDismissPublisher
            .sink { continuation.yield() }
          continuation.onTermination = { _ in
            sub?.cancel()
          }
        }
      }
    )
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
  
  var onTitleChanged: ((String) -> Void)?
  var navigationControllerProxy: NavigationControllerProxy?
  @ViewBuilder
  var content: Content
  
  @Environment(\.navigationController) private var parentNavigationProxy
  
  public var body: some View {
    content
      .onPreferenceChange(NavigationTitlePreferenceKey.self) { newValue in
        onTitleChanged?(newValue)
      }
      .environment(
        \.navigationController,
        navigationControllerProxy ?? parentNavigationProxy
      )
  }
}
