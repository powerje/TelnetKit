// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "TelnetKit",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "TelnetKit", targets: ["TelnetKit"]),
    ],
    dependencies: [
	.package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.0"),
	.package(url: "https://github.com/Nike-Inc/Willow.git", from: "5.0.2"),
    ],
    targets: [
        .target(
            name: "TelnetKit",
            dependencies: ["Socket", "Willow"]),
        .target(
            name: "TelnetKitDemo",
            dependencies: ["TelnetKit"],
            path: "TelnetKitDemo"),
        .testTarget(
            name: "TelnetKitTests",
            dependencies: ["TelnetKit"]),
    ]
)
