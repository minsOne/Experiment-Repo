import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureDemandDepositPackage",
    dependencies: .init(
        module: [
            .FeatureDemandDepositUI,
            .FeatureDemandDepositDomain,
        ])
)
