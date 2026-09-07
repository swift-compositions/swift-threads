// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-threads",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(name: "Thread Barrier", targets: ["Thread Barrier"]),
        .library(name: "Thread Gate", targets: ["Thread Gate"]),
        .library(name: "Thread Semaphore", targets: ["Thread Semaphore"]),
        .library(name: "Thread Worker", targets: ["Thread Worker"]),
        .library(name: "Thread Pool", targets: ["Thread Pool"]),
        .library(name: "Thread Actor", targets: ["Thread Actor"]),

        .library(name: "Threads", targets: ["Threads"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-compositions/swift-kernel.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-executors.git", branch: "main"),
        .package(
            url: "https://github.com/swift-compositions/swift-synchronizers.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-async.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-either.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Thread Barrier",
            dependencies: [
                .product(name: "Synchronizer Blocking", package: "swift-synchronizers")
            ]
        ),
        .target(
            name: "Thread Gate",
            dependencies: [
                .product(name: "Synchronizer Blocking", package: "swift-synchronizers")
            ]
        ),
        .target(
            name: "Thread Semaphore",
            dependencies: [
                .product(name: "Synchronizer Blocking", package: "swift-synchronizers")
            ]
        ),
        .target(
            name: "Thread Worker",
            dependencies: [
                .product(name: "Synchronizer Blocking", package: "swift-synchronizers")
            ]
        ),

        .target(
            name: "Thread Pool",
            dependencies: [
                .product(name: "Executors", package: "swift-executors"),
                .product(name: "Async Semaphore", package: "swift-async"),
                .product(name: "Cardinal Add", package: "swift-cardinal"),
                .product(name: "Cardinal Carrier", package: "swift-cardinal"),
                .product(name: "Cardinal Primitive", package: "swift-cardinal"),
                .product(
                    name: "Cardinal Standard Library Integration",
                    package: "swift-cardinal"
                ),
                .product(name: "Either", package: "swift-either"),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Synchronizer Blocking", package: "swift-synchronizers"),
            ]
        ),
        .target(
            name: "Thread Actor",
            dependencies: [
                .product(name: "Executors", package: "swift-executors")
            ]
        ),

        .target(
            name: "Threads",
            dependencies: [
                "Thread Barrier",
                "Thread Gate",
                "Thread Semaphore",
                "Thread Worker",
                "Thread Pool",
                "Thread Actor",
            ]
        ),

        .testTarget(
            name: "Thread Semaphore Tests",
            dependencies: [
                "Thread Semaphore",
                "Thread Gate",
                .product(name: "Kernel Test Support", package: "swift-kernel"),
            ]
        ),
        .testTarget(
            name: "Thread Pool Tests",
            dependencies: [
                "Thread Pool",
                "Thread Gate",
                .product(name: "Async Semaphore", package: "swift-async"),
                .product(name: "Kernel Test Support", package: "swift-kernel"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
