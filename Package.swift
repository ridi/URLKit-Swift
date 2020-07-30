// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "URLKit",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .watchOS(.v4),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "URLKit",
            type: .dynamic,
            targets: ["URLKit", "HTTPURLKit"]),
        .library(
            name: "URLKit-auto",
            targets: ["URLKit", "HTTPURLKit"]),
        .library(
            name: "RxURLKit",
            type: .dynamic,
            targets: ["RxURLKit", "RxHTTPURLKit"]),
        .library(
            name: "RxURLKit-auto",
            targets: ["RxHTTPURLKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "URLKit",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "URLKitTests",
            dependencies: ["URLKit"]),
        .target(
            name: "HTTPURLKit",
            dependencies: ["URLKit"]),
        .testTarget(
            name: "HTTPURLKitTests",
            dependencies: ["HTTPURLKit"]),
        .target(
            name: "RxURLKit",
            dependencies: ["RxSwift", "URLKit"]),
        .target(
            name: "RxHTTPURLKit",
            dependencies: ["RxSwift", "HTTPURLKit"]),
    ]
)
