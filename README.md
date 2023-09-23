# Stack Navigation

Stack Navigation은 SwiftUI의 NavigationStack과 유사하게 Path 상태를 기반으로 Destination들을 표시하는 UIKit 및 SwiftUI 용 라이브러리입니다.

## Requirements

- Swift 5.9 or later
- iOS 13 or later

## Usage

### SwiftUI

#### Stack Navigation (Global Destination)

1. 데이터 컬렉션 프로퍼티를 추가합니다.

```swift
@State private var presentedParks: [Park] = []
```

2. StackNavigationView와 데이터 컬렉션 값을 바인딩하고, `snNavigationDestination(for:destination:)`을 사용하여 Destination을 추가합니다.

```swift
StackNavigationView(path: $presentedParks) {
  List(parks) { park in
    Button(park.name) {
      presentedParks.append(park)
    }
  }
  .snNavigationDestination(for: Park.self) { park in
    ParkDetails(park: park)
  }
}
```

#### Tree Navigation (Local Destination)

1. Bool 프로퍼티를 추가합니다.

```swift
@State private var showDetails = false
var park: Park
```

2. StackNavigationView 내부에 모디파이어를 추가합니다.

```swift
StackNavigationView(path: $presentedParks) {
  VStack {
    Text(park.name)
    Button("Show details") {
      showDetails = true
    }
  }
  .snNavigationDestination(isPresented: $showDetails) {
    ParkDetails(park: park)
  }
}
```

### UIKit

#### Stack Navigation (Global Destination)

1. 내비게이션을 사용할 컨테이너(AppDelegate, ViewController 등)에서 이니셜라이즈합니다.

```swift
let navigationController = StackNavigationController(
  rootViewController: rootViewController,
  initialPath: viewModel.presentedParks,
  onPathChanged: { viewModel.presentedParks = $0 },
  destination: { ParkDetailsViewController(park: $0) }
)
```

2. 뷰 모델의 Path 변경시 update(using:) 메서드를 호출하여 뷰를 업데이트합니다.

```swift
let pathUpdate = viewModel.$presentedParks
  .sink { [weak navigationController] newPath in
    navigationController?.update(using: newPath)
  }
```

#### Tree Navigation (Local Destination)

기존 처럼 pushViewController를 사용합니다.

## UIKit 및 SwiftUI에서 동시 사용 (Tree)

### UIViewController에서 SwiftUI 뷰 Push하기

SwiftUI 뷰를 사용해 NavigationBindingController를 생성하고 Push합니다.

```swift
let swiftUIView: some View = // ...
let bindingController = NavigationBindingController(content: swiftUIView)
navigationController?.pushViewController(bindingController, animated: true)
```

### SwiftUI 뷰에서 UIViewController Push하기

아직 기능이 준비되지 않았습니다. 그러나 딱 한번 Push되고 이후 Push할 뷰컨트롤러가 없는 경우 UIViewControllerRepresentable을 사용하여 표시할 수 있습니다.

