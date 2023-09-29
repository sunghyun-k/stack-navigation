import SwiftUI

extension View {
  
  public func snNavigationDestination(
    isPresented: Binding<Bool>,
    @ViewBuilder destination: @escaping () -> some View
  ) -> some View {
    snNavigationDestination(isPresented: isPresented) {
      NavigationBindingController(content: destination())
    }
  }
  
  public func snNavigationDestination(
    isPresented: Binding<Bool>,
    destinationViewController: @escaping () -> UIViewController
  ) -> some View {
    modifier(
      LocalDestinationModifier(isPresented: isPresented, destination: destinationViewController)
    )
  }
}

fileprivate struct LocalDestinationModifier: ViewModifier {
  
  @Binding var isPresented: Bool
  var destination: () -> UIViewController
  
  @Variable private var oldIsPresented = false
  @Variable private var first = true
  @Environment(\.navigationController) private var navigationController
  
  func body(content: Content) -> some View {
    performNavigation(oldIsPresented: &oldIsPresented)
    return content
      .onAppear { sinkDismissStream() }
      .environmentObject(EmptyObject())
  }
  
  @MainActor
  private func performNavigation(oldIsPresented: inout Bool) {
    if isPresented == oldIsPresented { return }
    oldIsPresented = isPresented
    if isPresented {
      navigationController.pushViewController(destination())
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

/// View가 Disappear상태 시에도 modifier의 body 호출을 하기 위한 클래스. 자식에서 isPresented를 false로 바꿔도 pop되지 않는 문제를 수정한다.
fileprivate final class EmptyObject: ObservableObject { }
