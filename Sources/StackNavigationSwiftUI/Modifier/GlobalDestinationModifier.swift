import SwiftUI

extension View {
  
  public func snNavigationDestination<D: Hashable>(
    for data: D.Type,
    @ViewBuilder destination: @escaping (D) -> some View
  ) -> some View {
    modifier(GlobalDestinationModifier(data: data, destination: destination))
  }
}

fileprivate struct GlobalDestinationModifier<D: Hashable, C: View>: ViewModifier {
  
  var data: D.Type
  @ViewBuilder var destination: (D) -> C
  
  func body(content: Content) -> some View {
    content
      .transformPreference(DestinationBuilderStorageKey.self) { storage in
        storage[data] = .init(
          makeViewController: { datum in
            NavigationBindingController(content: destination(datum))
          },
          updateViewController: { vc, datum in
            vc.updateView(destination(datum))
          }
        )
      }
  }
}
