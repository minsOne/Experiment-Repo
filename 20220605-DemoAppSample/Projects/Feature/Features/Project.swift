import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "Features",
          platform: .iOS,
          product: .framework,
          bundleId: "kr.minsone.features",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .project(target: "FeatureDeposit", path: "../FeatureDeposit")
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1", "OTHER_LDFLAGS": "$(inherited) -all_load"])
         ),
    .init(name: "FeaturesDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.features.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "Features")
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         )
]

let project: Project =
    .init(name: "Features",
          organizationName: "minsone",
          targets: targets)
