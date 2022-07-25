//
//  Dependencies+Package.swift
//  ProjectDescriptionHelpers
//
//  Created by minsOne on 2022/07/25.
//

import ProjectDescription

extension TargetDependency {
    public struct Package {
        public static let FlexLayout: TargetDependency = .package(product: "FlexLayout")
        public static let PinLayout: TargetDependency = .package(product: "PinLayout")
    }
}

public extension Package {
    static let FlexLayout = Self.remote(url: "https://github.com/layoutBox/FlexLayout.git",
                                        requirement: .revision("2db7eaafbc9c988ca9ea4a236a41f67c07f7d1b6"))
    static let PinLayout = Self.remote(url: "https://github.com/layoutBox/PinLayout.git",
                                       requirement: .revision("f054f61b6c641a2298b2bedb05269f78cffb1b1c"))
}
