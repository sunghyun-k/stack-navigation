// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "stack-navigation",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "StackNavigation", targets: ["StackNavigation"]),
    .library(name: "StackNavigationSwiftUI", targets: ["StackNavigationSwiftUI"]),
  ],
  targets: [
    .target(name: "StackNavigation"),
    .target(
      name: "StackNavigationSwiftUI",
      dependencies: [
        "StackNavigation"
      ]
    ),
  ]
)
