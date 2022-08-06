import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureDeposit",
    dependencies: .init(
        module: [
            .DIContainer,
            .FeatureAuthInterface,
        ])
)
