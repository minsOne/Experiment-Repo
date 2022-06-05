import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "FeatureContainer",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.Container",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .project(target: "UIThirdPartyLibraryManager", path: "../../UIThirdPartyLibraryManager")
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureContainerDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.Container.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/Sources/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureContainer"),
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureContainerUnitTests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "kr.minsone.feature.Container.unitTests",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Tests/UIUnitTests/**"],
          dependencies: [.target(name: "FeatureContainer"),
                         .target(name: "FeatureContainerDemoApp")],
          settings: .settings(base: ["TEST_HOST": "",
                                     "BUNDLE_LOADER": "$(BUILT_PRODUCTS_DIR)/$(TEST_TARGET_NAME).app/$(TEST_TARGET_NAME)"])
         ),
]

let project: Project =
    .init(name: "FeatureContainer",
          organizationName: "minsone",
          packages: [
          ],
          targets: targets,
          schemes: [.init(name: "FeatureContainer",
                          shared: true,
                          buildAction: .buildAction(targets: ["FeatureContainer"]),
                          testAction: .targets(["FeatureContainerUnitTests"]))
                    ]
          )
