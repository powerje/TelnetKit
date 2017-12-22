// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TelnetKit",
    products: [
        .library(name: "TelnetKit", targets: ["TelnetKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sockets", from: "2.2.1"),
        .package(url: "https://github.com/Nike-Inc/Willow.git", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TelnetKit",
            dependencies: ["Sockets", "Willow"]),
        .target(
            name: "TelnetKitDemo",
            dependencies: ["TelnetKit"],
            path: "TelnetKitDemo"),
        .testTarget(
            name: "TelnetKitTests",
            dependencies: ["TelnetKit"]),
    ]
)
