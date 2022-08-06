import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureAuthInterface",
    dependencies: .init(
        module: [
            .DIContainer
        ])
)
