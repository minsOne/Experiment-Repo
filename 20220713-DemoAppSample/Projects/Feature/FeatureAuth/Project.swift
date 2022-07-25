import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "FeatureAuthUI",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.auth.ui",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/UI/**"],
          dependencies: [
//            .project(target: "FeatureContainer", path: "../FeatureContainer"),
            .project(target: "UIThirdPartyLibraryManager", path: "../../UIThirdPartyLibraryManager")
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureAuthUIPreviewApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.auth.uipreviewApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/UIPreviewApp/Sources/**"],
          resources: ["App/UIPreviewApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureAuthUI"),
            .package(product: "Inject"),
          ],
          settings: .settings(base: ["OTHER_LDFLAGS": "$(inherited) -Xlinker -interposable", "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureAuth",
          platform: .iOS,
          product: .staticLibrary,
          bundleId: "kr.minsone.feature.auth",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Source/Feature/**"],
          dependencies: [
            .target(name: "FeatureAuthUI"),
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureAuthDemoApp",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.feature.auth.demoApp",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/DemoApp/Sources/**"],
          resources: ["App/DemoApp/Resources/**"],
          dependencies: [
            .target(name: "FeatureAuth"),
            .package(product: "Inject"),
          ],
          settings: .settings(base: ["GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"])
         ),
    .init(name: "FeatureAuthUIUnitTests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "kr.minsone.feature.auth.uiunitTests",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Tests/UIUnitTests/**"],
          dependencies: [.target(name: "FeatureAuthUI"),
                         .target(name: "FeatureAuthUIPreviewApp")],
          settings: .settings(base: ["TEST_HOST": "",
                                     "BUNDLE_LOADER": "$(BUILT_PRODUCTS_DIR)/$(TEST_TARGET_NAME).app/$(TEST_TARGET_NAME)"])
         ),
    .init(name: "FeatureAuthUnitTests",
          platform: .iOS,
          product: .unitTests,
          bundleId: "kr.minsone.feature.auth.unitTests",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["Tests/UIUnitTests/**"],
          dependencies: [.target(name: "FeatureAuth"),
                         .target(name: "FeatureAuthDemoApp")],
          settings: .settings(base: ["TEST_HOST": "",
                                     "BUNDLE_LOADER": "$(BUILT_PRODUCTS_DIR)/$(TEST_TARGET_NAME).app/$(TEST_TARGET_NAME)"])
         ),
]

let project: Project =
    .init(name: "FeatureAuth",
          organizationName: "minsone",
          packages: [
            .remote(url: "https://github.com/krzysztofzablocki/Inject.git", requirement: .revision("0844cfbd6af3d30314adb49c8edf22168d254467")),
          ],
          targets: targets,
          schemes: [.init(name: "FeatureAuthUI",
                          shared: true,
                          testAction: .targets(["FeatureAuthUIUnitTests"])),
                    .init(name: "FeatureAuth",
                          shared: true,
                          testAction: .targets(["FeatureAuthUnitTests"])),
          ])
