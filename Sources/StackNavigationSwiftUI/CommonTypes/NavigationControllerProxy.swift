import SwiftUI

internal struct NavigationControllerProxy {
  var pushViewController: @MainActor (UIViewController) -> Void
  var popToSelf: @MainActor () -> Void
  var onDismiss: (@escaping @MainActor () -> Void) -> Void
}

extension NavigationControllerProxy: EnvironmentKey {
  static let defaultValue = Self(
    pushViewController: { _ in },
    popToSelf: { },
    onDismiss: { _ in }
  )
}

extension EnvironmentValues {
  internal var navigationController: NavigationControllerProxy {
    get { self[NavigationControllerProxy.self] }
    set { self[NavigationControllerProxy.self] = newValue }
  }
}
