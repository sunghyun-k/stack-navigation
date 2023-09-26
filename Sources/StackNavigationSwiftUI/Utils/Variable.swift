import SwiftUI

@propertyWrapper
internal struct Variable<Value>: DynamicProperty {
  
  private final class Storage {
    var value: Value
    init(_ value: Value) { self.value = value }
  }
  
  @State private var storage: Storage
  
  init(wrappedValue: Value) {
    self._storage = .init(wrappedValue: .init(wrappedValue))
  }
  
  var wrappedValue: Value {
    get { storage.value }
    nonmutating set { storage.value = newValue }
  }
}
