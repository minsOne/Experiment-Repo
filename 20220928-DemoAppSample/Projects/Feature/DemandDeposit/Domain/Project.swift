import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureDemandDepositDomain",
    dependencies: .init(
        module: [
            .FeatureDemandDepositInterface
        ])
)
