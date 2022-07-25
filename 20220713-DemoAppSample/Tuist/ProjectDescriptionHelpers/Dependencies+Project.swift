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

public extension TargetDependency {
    static let UIThirdPartyLibraryManager = Self.project(target: "UIThirdPartyLibraryManager",
                                                         path: .projects("UIThirdPartyLibraryManager"))
}
