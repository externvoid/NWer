// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NWer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NWer",
            targets: ["NWer"]),
        .executable(
          name: "upChartPlot",
          targets: ["upChartPlot"]),
    ],
    dependencies: [.package(url: "https://github.com/stephencelis/SQLite.swift",
                            .upToNextMajor(from: "0.15.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NWer",
            dependencies: [.product(name: "SQLite", package: "SQLite.swift")]),
        .target(
          name: "upChartPlot",
          dependencies: ["NWer"]),
        .testTarget(
            name: "NWerTests",
            dependencies: ["NWer"]),
        .testTarget(
          name: "upChartPlotTests",
          dependencies: ["NWer", "upChartPlot"]),
    ]
)
