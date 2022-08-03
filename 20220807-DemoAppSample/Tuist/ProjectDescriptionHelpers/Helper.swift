//
//  Helper.swift
//  ProjectDescriptionHelpers
//
//  Created by minsOne on 2022/07/25.
//

import Foundation
import ProjectDescription

public struct XCConfig {
    private struct Path {
        static var framework: ProjectDescription.Path { .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig") }
        static var example: ProjectDescription.Path { .relativeToRoot("Configurations/iOS/iOS-Example.xcconfig") }
        static var tests: ProjectDescription.Path { .relativeToRoot("Configurations/iOS/iOS-Tests.xcconfig") }
        static func project(_ config: String) -> ProjectDescription.Path { .relativeToRoot("Configurations/Base/Projects/Project-\(config).xcconfig") }
    }
    
    public static let framework: [Configuration] = [
        .debug(name: "Development", xcconfig: Path.framework),
        .debug(name: "Test", xcconfig: Path.framework),
        .release(name: "QA", xcconfig: Path.framework),
        .release(name: "Beta", xcconfig: Path.framework),
        .release(name: "Production", xcconfig: Path.framework),
    ]
    
    public static let tests: [Configuration] = [
        .debug(name: "Development", xcconfig: Path.tests),
        .debug(name: "Test", xcconfig: Path.tests),
        .release(name: "QA", xcconfig: Path.tests),
        .release(name: "Beta", xcconfig: Path.tests),
        .release(name: "Production", xcconfig: Path.tests),
    ]
    public static let example: [Configuration] = [
        .debug(name: "Development", xcconfig: Path.example),
        .debug(name: "Test", xcconfig: Path.example),
        .release(name: "QA", xcconfig: Path.example),
        .release(name: "Beta", xcconfig: Path.example),
        .release(name: "Production", xcconfig: Path.example),
    ]
    public static let project: [Configuration] = [
        .debug(name: "Development", xcconfig: Path.project("Development")),
        .debug(name: "Test", xcconfig: Path.project("Test")),
        .release(name: "QA", xcconfig: Path.project("QA")),
        .release(name: "Beta", xcconfig: Path.project("Beta")),
        .release(name: "Production", xcconfig: Path.project("Production")),
    ]
}

