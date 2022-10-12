import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .dynamicFramework(
    name: "SharedThirdPartyLibraryManager",
    organizationName: "minsone",
    packages: [
        .RIBs,
        .RxSwift
    ],
    dependencies: .init(
        module: [
            .Package.RIBs,
            .Package.RxSwift,
        ])
)
