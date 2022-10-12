//
//  Dependencies+Project.swift
//  ProjectDescriptionHelpers
//
//  Created by minsOne on 2022/07/25.
//

import ProjectDescription

extension Path {
    static func projects(_ name: String) -> Path {
        return .relativeToRoot("Projects/\(name)")
    }
}

public typealias Dep = TargetDependency

public extension TargetDependency {
    static let UIThirdPartyLibraryManager = Dep.project(target: "UIThirdPartyLibraryManager", path: .projects("UIThirdPartyLibraryManager"))
    static let SharedThirdPartyLibraryManager = Dep.project(target: "SharedThirdPartyLibraryManager", path: .projects("SharedThirdPartyLibraryManager"))
    static let DIContainer = Dep.project(target: "DIContainer", path: .projects("Feature/DIContainer"))
    static let FeatureAuth = Dep.project(target: "FeatureAuth", path: .projects("Feature/FeatureAuth"))
    static let FeatureAuthInterface = Dep.project(target: "FeatureAuthInterface", path: .projects("Feature/FeatureAuthInterface"))
    static let FeatureDeposit = Dep.project(target: "FeatureDeposit", path: .projects("Feature/FeatureDeposit"))

    static let FeatureDemandDepositPackage = Dep.project(target: "FeatureDemandDepositPackage", path: .projects("Feature/DemandDeposit/Package"))
    static let FeatureDemandDepositUI = Dep.project(target: "FeatureDemandDepositUI", path: .projects("Feature/DemandDeposit/UI"))
    static let FeatureDemandDepositDomain = Dep.project(target: "FeatureDemandDepositDomain", path: .projects("Feature/DemandDeposit/Domain"))
    static let FeatureDemandDepositInterface = Dep.project(target: "FeatureDemandDepositInterface", path: .projects("Feature/DemandDeposit/Interface"))
}
