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
  
  private struct Variables {
    var oldIsPresented = false
    var dismissStateUpdateTask: Task<Void, Never>?
  }
  @Variable private var variables = Variables()
  
  @Environment(\.navigationController) private var navigationController
  
  func body(content: Content) -> some View {
    performNavigation(oldIsPresented: &variables.oldIsPresented)
    return content
      .environmentObject(EmptyObject())
      .modifier(
        ReleaseTrackingModifier(
          onInit: { sinkDismissStream() },
          onDeinit: { variables.dismissStateUpdateTask?.cancel() }
        )
      )
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
    variables.dismissStateUpdateTask = Task {
      for await _ in navigationController.onDismissStream() {
        if isPresented { isPresented = false }
      }
    }
  }
}

/// View가 Disappear상태 시에도 modifier의 body 호출을 하기 위한 클래스. 자식에서 isPresented를 false로 바꿔도 pop되지 않는 문제를 수정한다.
fileprivate final class EmptyObject: ObservableObject { }

/// init과 deinit 시점에 호출되는 클로저를 저장할수 있는 모디파이어. init 클로저에선 SwiftUI State에 접근하거나 수정할수 없다.
fileprivate struct ReleaseTrackingModifier: ViewModifier {
  var onInit: @MainActor () -> Void
  var onDeinit: () -> Void
  func body(content: Content) -> some View {
    content.background(
      ReleaseTrackingView(
        onInit: onInit,
        onDeinit: onDeinit
      )
    )
  }
}

fileprivate struct ReleaseTrackingView: UIViewRepresentable {
  var onInit: @MainActor () -> Void
  var onDeinit: () -> Void
  func makeUIView(context: Context) -> DeinitHelperView {
    onInit()
    return DeinitHelperView(onDeinit: onDeinit)
  }
  func updateUIView(_ uiView: DeinitHelperView, context: Context) {
    
  }
}

fileprivate final class DeinitHelperView: UIView {
  var onDeinit: () -> Void
  
  init(onDeinit: @escaping () -> Void) {
    self.onDeinit = onDeinit
    super.init(frame: .zero)
  }
  required init?(coder: NSCoder) { fatalError() }
  deinit { onDeinit() }
}
