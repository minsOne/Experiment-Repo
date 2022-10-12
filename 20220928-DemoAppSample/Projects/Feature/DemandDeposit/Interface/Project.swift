import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "FeatureDemandDepositInterface",
    dependencies: .init(
        module: [
            .DIContainer,
            .SharedThirdPartyLibraryManager
        ])
)
