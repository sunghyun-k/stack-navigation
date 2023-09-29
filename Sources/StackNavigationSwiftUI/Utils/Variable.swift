import SwiftUI

/// View에 install하여 사용할 수 있는 변수. 뷰 업데이트를 방출하지 않는다.
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
