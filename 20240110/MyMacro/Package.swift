// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MyMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MyMacro",
            targets: ["MyMacro"]
        ),
        .executable(
            name: "MyMacroClient",
            targets: ["MyMacroClient"]
        ),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MyMacroMacros",
            dependencies: [
                .target(name: "SwiftSyntaxWrapper"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "MyMacro", dependencies: ["MyMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "MyMacroClient", dependencies: ["MyMacro"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MyMacroTests",
            dependencies: [
                "MyMacroMacros",
                .target(name: "SwiftSyntaxWrapper"),
            ]
        ),
        .binaryTarget(name: "SwiftSyntaxWrapper", path: "XCFramework/SwiftSyntaxWrapper.xcframework")
    ]
)
