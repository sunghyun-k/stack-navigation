import SwiftUI

internal struct NavigationControllerProxy {
  var pushViewController: @MainActor (UIViewController) -> Void
  var popToSelf: @MainActor () -> Void
  var onDismissStream: () -> AsyncStream<Void>
}

extension NavigationControllerProxy: EnvironmentKey {
  static let defaultValue = Self(
    pushViewController: { _ in },
    popToSelf: { },
    onDismissStream: { AsyncStream { $0.finish() } }
  )
}

extension EnvironmentValues {
  internal var navigationController: NavigationControllerProxy {
    get { self[NavigationControllerProxy.self] }
    set { self[NavigationControllerProxy.self] = newValue }
  }
}
