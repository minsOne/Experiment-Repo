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
    static let DIContainer = Dep.project(target: "DIContainer", path: .projects("Feature/DIContainer"))
    static let FeatureAuth = Dep.project(target: "FeatureAuth", path: .projects("Feature/FeatureAuth"))
    static let FeatureAuthInterface = Dep.project(target: "FeatureAuthInterface", path: .projects("Feature/FeatureAuthInterface"))
    static let FeatureDeposit = Dep.project(target: "FeatureDeposit", path: .projects("Feature/FeatureDeposit"))
}
