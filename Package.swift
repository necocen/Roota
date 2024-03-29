// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Roota",
                      platforms: [.iOS(.v9)],
                      products: [
                          .library(name: "Roota", targets: ["Roota"]),
                          .library(name: "RootaUI", targets: ["RootaUI"])
                      ],
                      dependencies: [
                          .package(url: "https://github.com/mxcl/PromiseKit", from: "6.0.0"),
                      ],
                      targets: [
                          .target(name: "Roota", dependencies: ["PromiseKit"], exclude: ["Info.plist", "Roota.h"]),
                          .target(name: "RootaUI", dependencies: ["Roota", "PromiseKit"], exclude: ["Info.plist", "RootaUI.h"])
                      ])
