import SwiftUI
import UIKit
import StackNavigation

public struct StackNavigationView<Content: View, Data>: View
  where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
        Data.Element: Hashable
{
  
  @Binding var path: Data
  var root: Content
  
  public init(path: Binding<Data>, @ViewBuilder root: () -> Content) {
    self._path = path
    self.root = root()
  }
  
  @Variable private var onDestinationsChange: ((DestinationBuilderStorage) -> Void)?
  
  public var body: some View {
    _StackNavigationView(
      path: $path,
      root: root,
      registerDestinationsChange: { onDestinationsChange = $0 }
    )
    .onPreferenceChange(DestinationBuilderStorageKey.self) {
      onDestinationsChange?($0)
    }
  }
}

fileprivate struct _StackNavigationView<Content: View, Data>: UIViewControllerRepresentable
  where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
        Data.Element: Hashable
{
  @Binding var path: Data
  var root: Content
  var registerDestinationsChange: (@escaping (DestinationBuilderStorage) -> Void) -> Void
  
  func makeUIViewController(context: Context) -> StackNavigationController<Data> {
    let rootVC = NavigationBindingController(content: root)
    context.coordinator.rootViewController = rootVC
    let nc = StackNavigationController<Data>(
      rootViewController: rootVC,
      initialPath: path
    )
    nc.stackDelegate = context.coordinator
    registerDestinationsChange { [weak nc] in nc?.destinations = $0 }
    return nc
  }
  
  func updateUIViewController(_ navigationController: StackNavigationController<Data>, context: Context) {
    func updateView() {
      if context.coordinator.isUpdatingState {
        context.coordinator.isUpdatingState = false
        return
      }
      navigationController.updateStacks(path)
    }
    
    updateView()
    context.coordinator.rootViewController?.updateView(root)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  @MainActor
  final class Coordinator: StackNavigationControllerDelegate {
    var parent: _StackNavigationView
    weak var rootViewController: NavigationBindingController<Content>?
    var isUpdatingState = false
    
    init(_ parent: _StackNavigationView) {
      self.parent = parent
    }
    
    func navigationController(didChangePath changedPath: Data) {
      parent.path = changedPath
    }
  }
}
