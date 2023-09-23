import class UIKit.UIViewController

public struct TypedDestinationBuilder<Datum, ViewController: UIViewController> {
  public var makeViewController: (Datum) -> ViewController
  public var updateViewController: (ViewController, Datum) -> Void
  public init(
    makeViewController: @escaping (Datum) -> ViewController,
    updateViewController: @escaping (ViewController, Datum) -> Void
  ) {
    self.makeViewController = makeViewController
    self.updateViewController = updateViewController
  }
}

package struct DestinationBuilder: Equatable {
  var key: ObjectIdentifier
  var makeViewController: (Any) -> UIViewController
  /// 타입이 일치하여 업데이트가 된 경우 true 반환
  var updateViewController: (UIViewController, Any) -> Bool
  
  package static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.key == rhs.key
  }
}

public struct DestinationBuilderStorage: Equatable {
  
  package var builders: [ObjectIdentifier: DestinationBuilder] = [:]
  
  public init() { }
  
  public subscript<D, VC: UIViewController>(key: D.Type) -> TypedDestinationBuilder<D, VC>? {
    get {
      guard let builder = builders[ObjectIdentifier(key)] else { return nil }
      return .init(
        makeViewController: { builder.makeViewController($0) as! VC },
        updateViewController: { _ = builder.updateViewController($0, $1) }
      )
    }
    set {
      let _key = ObjectIdentifier(key)
      if let newValue {
        builders[_key] = .init(
          key: _key,
          makeViewController: { newValue.makeViewController($0 as! D) },
          updateViewController: {
            guard let vc = $0 as? VC else { return false }
            newValue.updateViewController(vc, $1 as! D)
            return true
          }
        )
        
      } else {
        builders[_key] = nil
      }
    }
  }
  
  internal subscript<D>(datum datum: D) -> DestinationBuilder? {
    let base = (datum as? AnyHashable)?.base
    let type = type(of: base ?? datum)
    return builders[ObjectIdentifier(type)]
  }
}
