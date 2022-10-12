import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .dynamicFramework(
    name: "UIThirdPartyLibraryManager",
    organizationName: "minsone",
    packages: [
        .FlexLayout,
        .PinLayout
    ],
    dependencies: .init(
        module: [
            .Package.FlexLayout,
            .Package.PinLayout,
        ])
)
