//
//  NavigationBarHidden.swift
//
//
//  Created by Sunghyun Kim on 2024/01/06.
//

import SwiftUI

extension View {
  public func snNavigationBarHidden(_ hidden: Bool) -> some View {
    preference(key: NavigationBarHiddenKey.self, value: hidden)
  }
}

internal struct NavigationBarHiddenKey: PreferenceKey {
  static let defaultValue: Bool = false
  static func reduce(value: inout Bool, nextValue: () -> Bool) {
    value = nextValue()
  }
}
