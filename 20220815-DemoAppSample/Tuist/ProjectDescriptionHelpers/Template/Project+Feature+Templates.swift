//
//  Project+Feature+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by minsOne on 2022/07/25.
//

import Foundation
import ProjectDescription

public struct ModuleDependencies {
    public init(
        interface: [TargetDependency] = [],
        ui: [TargetDependency] = [],
        domain: [TargetDependency] = [],
        repo: [TargetDependency] = [],
        uiExample: [TargetDependency] = [],
        domainExample: [TargetDependency] = [],
        repoExample: [TargetDependency] = [],
        test: [TargetDependency] = []
    ) {
        self.interface = interface
        
        self.ui = ui
        self.domain = domain
        self.repo = repo
        
        self.uiExample = uiExample
        self.domainExample = domainExample
        self.repoExample = repoExample
        
        self.test = test
    }
    
    let interface: [TargetDependency]
    
    let ui: [TargetDependency]
    let domain: [TargetDependency]
    let repo: [TargetDependency]
    
    let uiExample: [TargetDependency]
    let domainExample: [TargetDependency]
    let repoExample: [TargetDependency]
    
    let test: [TargetDependency]
}

public extension Project {
    static func feature(name: String,
                        organizationName: String = "minsone",
                        deploymentTarget: DeploymentTarget = .iOS(targetVersion: "13.0", devices: .iphone),
                        packages: [Package] = [],
                        dependencies: ModuleDependencies = .init()) -> Self {
        
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
        
        /// MARK: - Interface Module
        do {
            let (target, scheme) = Feature.makeInterfaceTarget(name: name,
                                                               deploymentTarget: deploymentTarget,
                                                               dependencies: dependencies.interface,
                                                               configurationName: configurationName,
                                                               settings: settings)
            projectTargets.append(target)
            projectSchemes.append(scheme)
        }
        
        /// MARK: - UI Module
        do {
            let (target, scheme) = Feature.makeUITarget(name: name,
                                                        deploymentTarget: deploymentTarget,
                                                        dependencies: dependencies.ui,
                                                        configurationName: configurationName,
                                                        settings: settings)
            projectTargets.append(target)
            projectSchemes.append(scheme)
        }
        
        /// MARK: - Domain Module
        do {
            let (target, scheme) = Feature.makeDomainTarget(name: name,
                                                            deploymentTarget: deploymentTarget,
                                                            dependencies: dependencies.domain,
                                                            configurationName: configurationName,
                                                            settings: settings)
            projectTargets.append(target)
            projectSchemes.append(scheme)
        }
        
//        /// MARK: - Repository Module
//        do {
//            let (target, scheme) = Feature.makeRepositoryTarget(name: name,
//                                                                deploymentTarget: deploymentTarget,
//                                                                dependencies: dependencies.repo,
//                                                                configurationName: configurationName,
//                                                                settings: settings)
//            projectTargets.append(target)
//            projectSchemes.append(scheme)
//        }
//
//        /// MARK: - UI ExampleApp
//        do {
//            let (target, scheme) = Feature.makeUIExampleTarget(name: name,
//                                                               deploymentTarget: deploymentTarget,
//                                                               infoPlist: examplePlist,
//                                                               dependencies: dependencies.uiExample,
//                                                               configurationName: configurationName,
//                                                               settings: settings)
//            projectTargets.append(target)
//            projectSchemes.append(scheme)
//        }
//
//        /// MARK: - Domain ExampleApp
//        do {
//            let (target, scheme) = Feature.makeDomainExampleTarget(name: name,
//                                                                   deploymentTarget: deploymentTarget,
//                                                                   infoPlist: examplePlist,
//                                                                   dependencies: dependencies.domainExample,
//                                                                   configurationName: configurationName,
//                                                                   settings: settings)
//            projectTargets.append(target)
//            projectSchemes.append(scheme)
//        }
//
//        /// MARK: - Repository ExampleApp
//        do {
//
//            let (target, scheme) = Feature.makeRepositoryExampleTarget(name: name,
//                                                                       deploymentTarget: deploymentTarget,
//                                                                       infoPlist: examplePlist,
//                                                                       dependencies: dependencies.repoExample,
//                                                                       configurationName: configurationName,
//                                                                       settings: settings)
//            projectTargets.append(target)
//            projectSchemes.append(scheme)
//        }
//
//        /// MARK: - UI UnitTest
//        do {
//            let target = Feature.makeUITestTarget(name: name,
//                                                  deploymentTarget: deploymentTarget,
//                                                  dependencies: dependencies.test)
//
//            projectTargets.append(target)
//        }
//
//        /// MARK: - Domain UnitTest
//        do {
//            let target = Feature.makeDomainTestTarget(name: name,
//                                                      deploymentTarget: deploymentTarget,
//                                                      dependencies: dependencies.test)
//
//            projectTargets.append(target)
//        }
//
//        /// MARK: - Repository UnitTest
//        do {
//            let target = Feature.makeRepositoryTestTarget(name: name,
//                                                          deploymentTarget: deploymentTarget,
//                                                          dependencies: dependencies.test)
//
//            projectTargets.append(target)
//        }
        
        return Project(name: name,
                       organizationName: organizationName,
                       options: .options(automaticSchemesOptions: .disabled, disableBundleAccessors: true, disableShowEnvironmentVarsInScriptPhases: true, disableSynthesizedResourceAccessors: true),
                       packages: packages,
                       settings: .settings(configurations: XCConfig.project),
                       targets: projectTargets,
                       schemes: projectSchemes,
                       additionalFiles: ["Project.swift"]
        )
    }
}

private extension Project {
    struct Feature {}
}

private extension Project.Feature {
    static func makeInterfaceTarget(name: String,
                                    deploymentTarget: DeploymentTarget,
                                    dependencies: [TargetDependency],
                                    configurationName: ConfigurationName,
                                    settings: SettingsDictionary) -> (Target, Scheme) {
        let name = "\(name)Interface"
        var settings = settings
        settings["PRODUCT_NAME"] = "\(name)"

        let target = Target(name: "Interface",
                            platform: .iOS,
                            product: .staticLibrary,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Sources/Interface/*.swift"],
                            dependencies: dependencies,
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = Scheme(name: name,
                            shared: true,
                            hidden: false,
                            buildAction: .buildAction(targets: ["Interface"]),
                            runAction: .runAction(configuration: configurationName),
                            archiveAction: .archiveAction(configuration: configurationName),
                            profileAction: .profileAction(configuration: configurationName),
                            analyzeAction: .analyzeAction(configuration: configurationName))
        
        return (target, scheme)
    }
    
    static func makeUITarget(name: String,
                             deploymentTarget: DeploymentTarget,
                             dependencies: [TargetDependency],
                             configurationName: ConfigurationName,
                             settings: SettingsDictionary) -> (Target, Scheme) {
        let name = "\(name)UI"
        var settings = settings
        settings["PRODUCT_NAME"] = "\(name)"

        let target = Target(name: "UI",
                            platform: .iOS,
                            product: .staticLibrary,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Sources/Module/UI/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "Interface"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = Scheme(name: name,
                            shared: true,
                            hidden: false,
                            buildAction: .buildAction(targets: ["UI"]),
                            runAction: .runAction(configuration: configurationName),
                            archiveAction: .archiveAction(configuration: configurationName),
                            profileAction: .profileAction(configuration: configurationName),
                            analyzeAction: .analyzeAction(configuration: configurationName))
        
        return (target, scheme)
    }
    
    static func makeDomainTarget(name: String,
                                 deploymentTarget: DeploymentTarget,
                                 dependencies: [TargetDependency],
                                 configurationName: ConfigurationName,
                                 settings: SettingsDictionary) -> (Target, Scheme) {
        let _name = name
        let name = "\(name)Domain"
        var settings = settings
        settings["PRODUCT_NAME"] = "\(name)"

        let target = Target(name: "Domain",
                            platform: .iOS,
                            product: .staticLibrary,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Sources/Module/Domain/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "Interface"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = Scheme(name: name,
                            shared: true,
                            hidden: false,
                            buildAction: .buildAction(targets: ["Domain"]),
                            runAction: .runAction(configuration: configurationName),
                            archiveAction: .archiveAction(configuration: configurationName),
                            profileAction: .profileAction(configuration: configurationName),
                            analyzeAction: .analyzeAction(configuration: configurationName))
        
        return (target, scheme)
    }
    
    static func makeRepositoryTarget(name: String,
                                     deploymentTarget: DeploymentTarget,
                                     dependencies: [TargetDependency],
                                     configurationName: ConfigurationName,
                                     settings: SettingsDictionary) -> (Target, Scheme) {
        let _name = name
        let name = "\(name)Repository"
        var settings = settings
        settings["PRODUCT_NAME"] = "\(name)"

        let target = Target(name: "Repository",
                            platform: .iOS,
                            product: .staticFramework,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Sources/Module/Repository/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "Interface"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = makeScheme(name: name,
                                testName: "\(name)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
}

private extension Project.Feature {
    static func makeUIExampleTarget(name: String,
                                    deploymentTarget: DeploymentTarget,
                                    infoPlist: InfoPlist,
                                    dependencies: [TargetDependency],
                                    configurationName: ConfigurationName,
                                    settings: SettingsDictionary) -> (Target, Scheme) {
        let moduleName = "\(name)UI"
        let name = "\(moduleName)Example"
        let target = Target(name: "UIExample",
                            platform: .iOS,
                            product: .app,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: infoPlist,
                            sources: ["Example/Sources/UI/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "UI"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = makeScheme(name: name,
                                testName: "\(moduleName)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
    
    static func makeDomainExampleTarget(name: String,
                                        deploymentTarget: DeploymentTarget,
                                        infoPlist: InfoPlist,
                                        dependencies: [TargetDependency],
                                        configurationName: ConfigurationName,
                                        settings: SettingsDictionary) -> (Target, Scheme) {
        let moduleName = "\(name)Domain"
        let name = "\(moduleName)Example"
        let target = Target(name: "DomainExample",
                            platform: .iOS,
                            product: .app,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: infoPlist,
                            sources: ["Example/Sources/Domain/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "Domain"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = makeScheme(name: name,
                                testName: "\(moduleName)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
    
    static func makeRepositoryExampleTarget(name: String,
                                            deploymentTarget: DeploymentTarget,
                                            infoPlist: InfoPlist,
                                            dependencies: [TargetDependency],
                                            configurationName: ConfigurationName,
                                            settings: SettingsDictionary) -> (Target, Scheme) {
        let moduleName = "\(name)Repository"
        let name = "\(moduleName)Example"
        let target = Target(name: "RepositoryExample",
                            platform: .iOS,
                            product: .app,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: infoPlist,
                            sources: ["Example/Sources/Repository/*.swift"],
                            dependencies: [
                                dependencies,
                                [
                                    .target(name: "Repository"),
                                ]
                            ].flatMap { $0 },
                            settings: .settings(base: settings, configurations: XCConfig.framework))
        
        let scheme = makeScheme(name: name,
                                testName: "\(moduleName)UnitTests",
                                configurationName: configurationName)
        
        return (target, scheme)
    }
}

private extension Project.Feature {
    static func makeUITestTarget(name: String,
                                 deploymentTarget: DeploymentTarget,
                                 dependencies: [TargetDependency]) -> Target {
        let name = "\(name)UIUnitTests"
        let target = Target(name: name,
                            platform: .iOS,
                            product: .unitTests,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Tests/Sources/UI/*.swift"],
                            resources: [.glob(pattern: "Tests/Resources/UI/**",
                                              excluding: ["Tests/Resources/UI/dummy.txt"])],
                            dependencies: [
                                dependencies,
                                [
                                    .xctest,
                                ]
                            ].flatMap { $0 },
                            settings: .settings(configurations: XCConfig.tests))
        
        return target
    }
    
    static func makeDomainTestTarget(name: String,
                                     deploymentTarget: DeploymentTarget,
                                     dependencies: [TargetDependency]) -> Target {
        let name = "\(name)DomainUnitTests"
        let target = Target(name: name,
                            platform: .iOS,
                            product: .unitTests,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Tests/Sources/Domain/*.swift"],
                            resources: [.glob(pattern: "Tests/Resources/Domain/**",
                                              excluding: ["Tests/Resources/Domain/dummy.txt"])],
                            dependencies: [
                                dependencies,
                                [
                                    .xctest,
                                ]
                            ].flatMap { $0 },
                            settings: .settings(configurations: XCConfig.tests))
        
        return target
    }
    
    static func makeRepositoryTestTarget(name: String,
                                         deploymentTarget: DeploymentTarget,
                                         dependencies: [TargetDependency]) -> Target {
        let name = "\(name)RepositoryUnitTests"
        let target = Target(name: name,
                            platform: .iOS,
                            product: .unitTests,
                            bundleId: "kr.minsone.\(name)",
                            deploymentTarget: deploymentTarget,
                            infoPlist: .default,
                            sources: ["Tests/Sources/Repository/*.swift"],
                            resources: [.glob(pattern: "Tests/Resources/Repository/**",
                                              excluding: ["Tests/Resources/Repository/dummy.txt"])],
                            dependencies: [
                                dependencies,
                                [
                                    .xctest,
                                ]
                            ].flatMap { $0 },
                            settings: .settings(configurations: XCConfig.tests))
        
        return target
    }
}

private extension Project.Feature {
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
