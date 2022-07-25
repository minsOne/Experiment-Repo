//
//  Project+DynamicFramework+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by minsOne on 2022/07/25.
//

import Foundation
import ProjectDescription

public struct DynamicFrameworkDependencies {
    public init(module: [TargetDependency] = [],
                demoApp: [TargetDependency] = []) {
        self.module = module
        self.demoApp = demoApp
    }
    
    let module: [TargetDependency]
    let demoApp: [TargetDependency]
}


public extension Project {
    static func dynamicFramework(name: String,
                                 organizationName: String = "minsone",
                                 deploymentTarget: DeploymentTarget = .iOS(targetVersion: "13.0", devices: .iphone),
                                 packages: [Package] = [],
                                 dependencies: DynamicFrameworkDependencies = .init()) -> Self {
        let configurationName: ConfigurationName = "Test"
        let settings: SettingsDictionary = ["OTHER_LDFLAGS" : "$(inherited) -all_load",
                                            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"]
        let examplePlist: InfoPlist = .extendingDefault(with: [
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen",
            "LSSupportsOpeningDocumentsInPlace": true,
            "UIFileSharingEnabled": true,
        ])
        
        var projectTargets: [Target] = []
        var projectSchemes: [Scheme] = []
        
        /// MARK: - StaticFramework
        do {
            let (target, scheme) = StaticFramework
                .makeDynamicFrameworkTarget(name: name,
                                            deploymentTarget: deploymentTarget,
                                            dependencies: dependencies.module,
                                            configurationName: configurationName,
                                            settings: settings)
            projectTargets.append(target)
            projectSchemes.append(scheme)
        }
        
        /// MARK: Example
        do {
            let (target, scheme) = StaticFramework
                .makeExampleTarget(name: name,
                                   deploymentTarget: deploymentTarget,
                                   infoPlist: examplePlist,
                                   dependencies: dependencies.demoApp,
                                   configurationName: configurationName,
                                   settings: settings)
            projectTargets.append(target)
            projectSchemes.append(scheme)
        }
        
        return Project(name: name,
                       organizationName: organizationName,
                       packages: packages,
                       settings: .settings(configurations: XCConfig.project),
                       targets: projectTargets,
                       schemes: projectSchemes)
    }
}

private extension Project {
    struct StaticFramework {}
}

private extension Project.StaticFramework {
    static func makeDynamicFrameworkTarget(name: String,
                                           deploymentTarget: DeploymentTarget,
                                           dependencies: [TargetDependency],
                                           configurationName: ConfigurationName,
                                           settings: SettingsDictionary) -> (Target, Scheme) {
        let target = Target(name: name,
                            platform: .iOS,
                            product: .framework,
                            productName: name,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Sources/**/*.swift"],
                            dependencies: dependencies,
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        let scheme = makeScheme(name: name,
                                testName: "\(name)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
    
    static func makeExampleTarget(name: String,
                                  deploymentTarget: DeploymentTarget,
                                  infoPlist: InfoPlist,
                                  dependencies: [TargetDependency],
                                  configurationName: ConfigurationName,
                                  settings: SettingsDictionary) -> (Target, Scheme) {
        let moduleName = name
        let name = "\(moduleName)DemoApp"
        let target = Target(name: name,
                            platform: .iOS,
                            product: .app,
                            productName: name,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: infoPlist,
                            sources: ["App/DemoApp/**/*.swift"],
                            resources: [.glob(pattern: "App/DemoApp/Resources/**", excluding: ["App/DemoApp/Resources/dummy.txt"])],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: moduleName)
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = makeScheme(name: name,
                                testName: "\(moduleName)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
    
    static func makeUnitTestTarget(name: String,
                                   deploymentTarget: DeploymentTarget,
                                   dependencies: [TargetDependency],
                                   configurationName: ConfigurationName) -> Target {
        return Target(
            name: "\(name)UnitTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "kr.minsone.\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/Sources/**/*.swift"],
            resources: [.glob(pattern: "Tests/Resources/**", excluding: ["Tests/Resources/dummy.txt"])],
            dependencies: [
                dependencies,
                [
                    .xctest,
                    .target(name: "\(name)DemoApp"),
                ],
            ].flatMap { $0 },
            settings: .settings(base: [:], configurations: XCConfig.tests))
    }
}


private extension Project.StaticFramework {
    static func makeScheme(name: String,
                           testName: String,
                           hidden: Bool = false,
                           configurationName: ConfigurationName) -> Scheme {
        return Scheme(name: name,
                      shared: true,
                      hidden: hidden,
                      buildAction: .buildAction(targets: ["\(name)"]),
                      testAction: .targets(["\(testName)"], configuration: configurationName),
                      runAction: .runAction(configuration: configurationName),
                      archiveAction: .archiveAction(configuration: configurationName),
                      profileAction: .profileAction(configuration: configurationName),
                      analyzeAction: .analyzeAction(configuration: configurationName))
    }
}
