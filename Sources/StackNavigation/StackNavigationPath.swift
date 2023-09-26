public struct StackNavigationPath {
  internal var elements: [AnyHashable]
  
  public init(_ elements: some Sequence<some Hashable>) {
    self.elements = Array(elements)
  }
  
  public init(_ elements: some Sequence<some Hashable & Codable>) {
    self.elements = Array(elements)
    // codable 추가 동작
  }
  
  public var count: Int { elements.count }
  public var isEmpty: Bool { elements.isEmpty }
  
//  public var codable
  
  public mutating func append<V: Hashable>(_ value: V) {
    elements.append(value)
  }
  
  public mutating func append<V>(_ value: V) where V: Codable & Hashable {
    elements.append(value)
    // codable 추가 동작
  }
  
  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(k)
  }
}

extension StackNavigationPath: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.elements == rhs.elements
  }
}
