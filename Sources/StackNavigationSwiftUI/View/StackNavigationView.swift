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
  
  @State private var destinations = DestinationBuilderStorage()
  
  public var body: some View {
    _StackNavigationView(path: $path, root: root, destinations: destinations)
      .onPreferenceChange(DestinationBuilderStorageKey.self) {
        destinations = $0
      }
  }
}

fileprivate struct _StackNavigationView<Content: View, Data>: UIViewControllerRepresentable
  where Data: MutableCollection & RandomAccessCollection & RangeReplaceableCollection,
        Data.Element: Hashable
{
  @Binding var path: Data
  var root: Content
  var destinations: DestinationBuilderStorage
  
  func makeUIViewController(context: Context) -> StackNavigationController<Data> {
    let rootVC = NavigationBindingController(content: root)
    context.coordinator.rootViewController = rootVC
    return StackNavigationController<Data>(
      rootViewController: rootVC,
      initialPath: path,
      onPathChanged: { [weak coordinator = context.coordinator] newPath in
        coordinator?.isUpdatingState = true
        path = newPath
      }
    )
  }
  
  func updateUIViewController(_ navigationController: StackNavigationController<Data>, context: Context) {
    func updateView() {
      if context.coordinator.isUpdatingState {
        context.coordinator.isUpdatingState = false
        return
      }
      navigationController.updateStacks(path)
    }
    
    navigationController.destinations = destinations
    updateView()
    context.coordinator.rootViewController?.updateView(root)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  @MainActor
  final class Coordinator {
    weak var rootViewController: NavigationBindingController<Content>?
    var isUpdatingState = false
  }
}
