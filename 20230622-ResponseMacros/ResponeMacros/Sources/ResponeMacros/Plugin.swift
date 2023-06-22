import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ResponeMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ResponseInitMacro.self,
        ResponseJSONMacro.self,
    ]
}

