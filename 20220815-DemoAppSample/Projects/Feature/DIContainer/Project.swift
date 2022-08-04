import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .staticFramework(
    name: "DIContainer",
    dependencies: .init(
        module: [
            .UIThirdPartyLibraryManager
        ])
)
