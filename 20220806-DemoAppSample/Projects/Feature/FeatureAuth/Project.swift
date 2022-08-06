import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureAuth",
    dependencies: .init(
        module: [
            .DIContainer,
            .FeatureAuthInterface,
        ])
)
