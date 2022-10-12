import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureDemandDepositUI",
    dependencies: .init(
        module: [
            .FeatureDemandDepositInterface
        ])
)
