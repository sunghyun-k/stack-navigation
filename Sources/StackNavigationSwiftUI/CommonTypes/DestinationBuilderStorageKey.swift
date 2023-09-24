import SwiftUI
@_spi(package) import struct StackNavigation.DestinationBuilderStorage

internal struct DestinationBuilderStorageKey: PreferenceKey {
  static let defaultValue = DestinationBuilderStorage()
  static func reduce(value: inout DestinationBuilderStorage, nextValue: () -> DestinationBuilderStorage) {
    for (key, builder) in nextValue().builders {
      value.builders[key] = builder
    }
  }
}
