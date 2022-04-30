import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "FeatureDepositUI",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.deposit.ui",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/UI/**"]
         ),
    .init(name: "FeatureDepositUIPreviewApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.deposit.uipreviewApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/UIPreviewApp/Sources/**"],
          resources: ["App/UIPreviewApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureDepositUI"),
            .package(product: "Inject"),
          ],
          settings: .settings(base: ["OTHER_LDFLAGS": "$(inherited) -Xlinker -interposable"])
         ),
    .init(name: "FeatureDeposit",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.deposit",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .target(name: "FeatureDepositUI")
          ]
         ),
    .init(name: "FeatureDepositDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.deposit.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/Sources/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureDeposit"),
            .package(product: "Inject"),
          ]
         )
]

let project: Project =
    .init(name: "FeatureDeposit",
          organizationName: "minsone",
          packages: [.remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .revision("0844cfbd6af3d30314adb49c8edf22168d254467"))],
          targets: targets)
