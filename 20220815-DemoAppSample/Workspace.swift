
import ProjectDescription

let workspace = Workspace.create()

extension Workspace {
    
    static func create() -> Workspace {
        Workspace(
            name: "Application",
            projects: [
                "Projects/**",
            ],
            additionalFiles: [.glob(pattern: .relativeToRoot("Tuist/**"))],
            generationOptions: .options(enableAutomaticXcodeSchemes: false,
                                        autogeneratedWorkspaceSchemes: .disabled,
                                        renderMarkdownReadme: true)
        )
    }
    
}