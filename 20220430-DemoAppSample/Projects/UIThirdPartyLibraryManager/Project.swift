import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "UIThirdPartyLibraryManager",
          platform: .iOS,
          product: .framework,
          bundleId: "kr.minsone.uiThirdPartyLibraryManager",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/**"],
          dependencies: [
            .package(product: "FlexLayout"),
            .package(product: "PinLayout"),
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "UIThirdPartyLibraryManagerDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.uiThirdPartyLibraryManager.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "UIThirdPartyLibraryManager")
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         )
]

let project: Project =
    .init(name: "UIThirdPartyLibraryManager",
          organizationName: "minsone",
          packages: [
            .remote(url: "https://github.com/layoutBox/FlexLayout.git", requirement: .revision("2db7eaafbc9c988ca9ea4a236a41f67c07f7d1b6")),
            .remote(url: "https://github.com/layoutBox/PinLayout.git", requirement: .revision("f054f61b6c641a2298b2bedb05269f78cffb1b1c")),
          ],
          targets: targets)
