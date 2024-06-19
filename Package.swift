// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HIPAAChecker-xPlugin",
    platforms: [
            .iOS(.v11)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HIPAAChecker-xPlugin", targets: ["HIPAAChecker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.2.1")),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.9.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", .upToNextMajor(from: "1.2.0")),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HIPAAChecker",
            dependencies: ["HIPAACheckerCore"],
            resources: []
        ),
        
        .target(
            name: "HIPAACheckerCore",
            dependencies: [
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),

            ]
        ),
        .testTarget(
            name: "HIPAACheckerTests",
            dependencies: ["HIPAAChecker"]),
    ]
)
