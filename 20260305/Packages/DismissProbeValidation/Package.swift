// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DismissProbeValidation",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DismissProbeValidation",
            targets: ["DismissProbeValidation"]
        )
    ],
    targets: [
        .target(
            name: "DismissProbeValidation",
            path: "Sources/DismissProbeValidation"
        )
    ]
)
