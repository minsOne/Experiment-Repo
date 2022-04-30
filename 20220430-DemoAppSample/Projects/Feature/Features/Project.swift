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
          ]
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
          ]
         )
]

let project: Project =
    .init(name: "Features",
          organizationName: "minsone",
          targets: targets)
