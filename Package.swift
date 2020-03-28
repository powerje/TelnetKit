// swift-tools-version:5.2

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
	.package(name: "Socket", url: "https://github.com/IBM-Swift/BlueSocket.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TelnetKit",
            dependencies: ["Socket"]),
        .target(
            name: "TelnetKitDemo",
            dependencies: ["TelnetKit"],
            path: "TelnetKitDemo"),
        .testTarget(
            name: "TelnetKitTests",
            dependencies: ["TelnetKit"]),
    ]
)
