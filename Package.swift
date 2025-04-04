// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorWeb3auth",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorWeb3auth",
            targets: ["CapWeb3AuthPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "CapWeb3AuthPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/CapWeb3AuthPlugin"),
        .testTarget(
            name: "CapWeb3AuthPluginTests",
            dependencies: ["CapWeb3AuthPlugin"],
            path: "ios/Tests/CapWeb3AuthPluginTests")
    ]
)