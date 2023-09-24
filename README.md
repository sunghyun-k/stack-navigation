# Stack Navigation

Stack Navigation is a library for UIKit and SwiftUI that displays destinations based on the path state, similar to SwiftUI's NavigationStack.

Stack Navigation은 SwiftUI의 NavigationStack과 유사하게 Path 상태를 기반으로 Destination들을 표시하는 UIKit 및 SwiftUI 용 라이브러리입니다.

## Requirements

- Swift 5.9 or later
- iOS 13 or later

## Usage

### With SwiftUI

#### Stack based navigation (Global destination)

1. Add data collection property.

   데이터 컬렉션 프로퍼티를 추가합니다.

```swift
@State private var presentedParks: [Park] = []
```

2. Bind the StackNavigationView to a data collection value and add a Destination using `snNavigationDestination(for:destination:)`.

   StackNavigationView와 데이터 컬렉션 값을 바인딩하고, `snNavigationDestination(for:destination:)`을 사용하여 Destination을 추가합니다.

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

#### Tree based navigation (Local destination)

1. Add a bool property.

   Bool 프로퍼티를 추가합니다.

```swift
@State private var showDetails = false
var park: Park
```

2. Add a modifier inside StackNavigationView.

   StackNavigationView 내부에 모디파이어를 추가합니다.

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

#### Change navigation title

Add snNavigationTitle(:) modifier in the Root View or Destination View.

snNavigationTitle(:) 모디파이어를 Root View 또는 Destination View에서 호출합니다.

```swift
content
  .snNavigationTitle(park.name)
```

### With UIKit

#### Stack based navigation (Global destination)

1. Initialize the navigation in the container such as AppDelegate, ViewController, etc.

   내비게이션을 사용할 컨테이너(AppDelegate, ViewController 등)에서 이니셜라이즈합니다.

```swift
let navigationController = StackNavigationController(
  rootViewController: rootViewController,
  initialPath: viewModel.presentedParks,
  onPathChanged: { viewModel.presentedParks = $0 },
  destination: { ParkDetailsViewController(park: $0) }
)
```

2. When the Path of the view model changes, call the `update(using:)` method to update the view.

   뷰 모델의 Path 변경시 `update(using:)` 메서드를 호출하여 뷰를 업데이트합니다.

```swift
let pathUpdate = viewModel.$presentedParks
  .sink { [weak navigationController] newPath in
    navigationController?.update(using: newPath)
  }
```

#### Tree based navigation (Local destination)

Use pushViewController as usual.

기존 처럼 pushViewController를 사용합니다.

## Move between UIKit and SwiftUI (Tree based)

### Pushing SwiftUI View from UIViewController

Create a NavigationBindingController using SwiftUI views and push it.

SwiftUI 뷰를 사용해 NavigationBindingController를 생성하고 Push합니다.

```swift
let parkDetailsView: some View = ParkDetails(park: park)
let bindingController = NavigationBindingController(content: parkDetailsView)
navigationController?.pushViewController(bindingController, animated: true)
```

### Pushing UIViewController from SwiftUI view

Define a Destination View Controller using the `snNavigationDestination(isPresented:destinationViewController:)` modifier.

`snNavigationDestination(isPresented:destinationViewController:)` 모디파이어를 사용하여 Destination View Controller를 정의합니다.

```swift
content
  .snNavigationDestination(isPresented: $showDetails) {
    ParkDetailsViewController(park: park)
  }
```

## To do

- NavigationLink
   - Local `NavigationLink(destination:label:)`
   - Global `NavigationLink(value:label:)`
- NavigationPath
   - CodableRepresentation

