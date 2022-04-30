import ProjectDescription
import ProjectDescriptionHelpers

let targets: [Target] = [
    .init(name: "Application",
          platform: .iOS,
          product: .app,
          bundleId: "kr.minsone.app",
          deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
          sources: ["App/Sources/**"],
          resources: ["App/Resources/**"],
          dependencies: [
            .project(target: "Features", path: "../Feature/Features")
          ]
         )
]

let project = Project.init(name: "Application",
                           organizationName: "minsone",
                           targets: targets)
