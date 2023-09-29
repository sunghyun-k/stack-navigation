import SwiftUI

public struct SNDismissAction: EnvironmentKey {
  var action: @MainActor () -> Void
  @MainActor
  public func callAsFunction() {
    action()
  }
  
  public static let defaultValue = Self(action: { })
}

extension EnvironmentValues {
  public internal(set) var snDismiss: SNDismissAction {
    get { self[SNDismissAction.self] }
    set { self[SNDismissAction.self] = newValue }
  }
}
