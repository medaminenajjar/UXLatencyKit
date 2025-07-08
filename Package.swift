// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UXLatencyKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UXLatencyKit",
            targets: ["UXLatencyKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector.git",
                 exact: "0.9.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UXLatencyKit"
        ),
        .testTarget(
            name: "UXLatencyKitTests",
            dependencies: ["UXLatencyKit",
                           .product(name: "ViewInspector", package: "ViewInspector")]
        ),
    ]
)
