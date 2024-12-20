// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "XUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "XUI",
            targets: ["XUI"]
        ),
        .library(
            name: "XList",
            targets: ["XList"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.0"),
        .package(url: "https://github.com/xueqooy/XKit", from: "1.0.0"),
        .package(url: "https://github.com/Instagram/IGListKit", from: "5.0.0"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa", from: "0.0.0"),
    ],
    targets: [
        .target(
            name: "XUI",
            dependencies: ["_XUILoader", "SnapKit", "XKit", "CombineCocoa"],
            path: "Source/XUI",
            resources: [
                .process("resources"),
            ]
        ),
        .target(
            name: "XList",
            dependencies: [
                "XKit", "XUI", "SnapKit",
                .product(name: "IGListDiffKit", package: "IGListKit"),
                .product(name: "IGListKit", package: "IGListKit"),
                .product(name: "IGListSwiftKit", package: "IGListKit"),
            ],
            path: "Source/XList"
        ),
        .target(
            name: "_XUILoader",
            path: "Source/_XUILoader"
        ),
    ],
    swiftLanguageVersions: [.v5],
    cLanguageStandard: .c11
)
