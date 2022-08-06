import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .dynamicFramework(
    name: "Features",
    dependencies: .init(
        module: [
            .FeatureAuth,
            .FeatureDeposit,
            .UIThirdPartyLibraryManager,
        ])
)
