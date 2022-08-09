import ProjectDescription
import ProjectDescriptionHelpers

func appProject() -> Project {
    let configurationName: ConfigurationName = "Test"
    let settings: SettingsDictionary = [
        "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) FLEXLAYOUT_SWIFT_PACKAGE=1"
    ]
    let targets: [Target] = [
        .init(name: "Application",
              platform: .iOS,
              product: .app,
              bundleId: "kr.minsone.app",
              deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
              sources: ["App/Sources/**"],
              resources: ["App/Resources/**"],
              scripts: [
                .pre(script: "echo $LD_DEPENDENCY_INFO_FILE", name: "Print LD_DEPENDENCY_INFO_FILE")
              ],
              dependencies: [
                .project(target: "Features", path: "../Feature/Features")
              ],
              settings: .settings(base: settings, configurations: XCConfig.example))
    ]
    
    let schemes: [Scheme] = [
        makeScheme(configurationName: configurationName)
    ]
    
    return Project(name: "Application",
                   organizationName: "minsone",
                   settings: .settings(configurations: XCConfig.project),
                   targets: targets,
                   schemes: schemes,
                   additionalFiles: ["Project.swift"])
}

func makeScheme(configurationName: ConfigurationName) -> Scheme {
    return Scheme(name: "App",
                  shared: true,
                  hidden: false,
                  buildAction: .buildAction(targets: ["Application"]),
                  runAction: .runAction(configuration: configurationName),
                  archiveAction: .archiveAction(configuration: configurationName),
                  profileAction: .profileAction(configuration: configurationName),
                  analyzeAction: .analyzeAction(configuration: configurationName))

}



let project = appProject()
