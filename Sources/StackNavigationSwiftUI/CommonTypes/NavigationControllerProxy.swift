import SwiftUI

internal struct NavigationControllerProxy {
  var pushViewController: @MainActor (UIViewController) -> Void
  var popToSelf: @MainActor () -> Void
  var onChildDismissStream: () -> AsyncStream<Void>
}

extension NavigationControllerProxy: EnvironmentKey {
  static let defaultValue = Self(
    pushViewController: { _ in },
    popToSelf: { },
    onChildDismissStream: { AsyncStream { $0.finish() } }
  )
}

extension EnvironmentValues {
  internal var navigationController: NavigationControllerProxy {
    get { self[NavigationControllerProxy.self] }
    set { self[NavigationControllerProxy.self] = newValue }
  }
}
