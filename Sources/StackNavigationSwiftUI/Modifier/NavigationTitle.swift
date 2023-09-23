import SwiftUI

extension View {
  
  public func snNavigationTitle(_ title: String) -> some View {
    preference(key: NavigationTitlePreferenceKey.self, value: title)
  }
}

internal struct NavigationTitlePreferenceKey: PreferenceKey {
  static let defaultValue: String = ""
  static func reduce(value: inout String, nextValue: () -> String) {
    value = nextValue()
  }
}
