
import ProjectDescription

let workspace = Workspace.create()

extension Workspace {
    
    static func create() -> Workspace {
        Workspace(
            name: "Application",
            projects: [
                "Projects/**",
            ],
            schemes: [],
            additionalFiles: [.glob(pattern: .relativeToRoot("Tuist/**"))]
        )
    }
    
}
