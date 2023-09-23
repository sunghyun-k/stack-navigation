import SwiftUI

extension View {
  
  public func snNavigationDestination(
    isPresented: Binding<Bool>,
    @ViewBuilder destination: @escaping () -> some View
  ) -> some View {
    modifier(
      LocalDestinationModifier(
        isPresented: isPresented,
        destination: destination
      )
    )
    .environmentObject(EmptyObject())
  }
}

fileprivate struct LocalDestinationModifier<V: View>: ViewModifier {
  
  @Binding var isPresented: Bool
  @ViewBuilder var destination: V
  init(isPresented: Binding<Bool>, destination: () -> V) {
    self._isPresented = isPresented
    self.destination = destination()
  }
  
  @Variable private var oldIsPresented = false
  @Variable private var first = true
  @Environment(\.navigationController) private var navigationController
  
  @EnvironmentObject private var object: EmptyObject
  
  func body(content: Content) -> some View {
    performNavigation(oldIsPresented: &oldIsPresented)
    return content
      .onAppear {
        sinkDismissStream()
      }
      .environmentObject(object)
  }
  
  @MainActor
  private func performNavigation(oldIsPresented: inout Bool) {
    if isPresented == oldIsPresented { return }
    oldIsPresented = isPresented
    if isPresented {
      navigationController.pushViewController(NavigationBindingController(content: destination))
    } else {
      navigationController.popToSelf()
    }
  }
  
  private func sinkDismissStream() {
    if first {
      first = false
      
      navigationController.onDismiss {
        if isPresented { isPresented = false }
      }
    }
  }
}

/// View가 Disappear되었을 시에도 modifier 호출을 하기 위한 클래스.
fileprivate final class EmptyObject: ObservableObject { }
