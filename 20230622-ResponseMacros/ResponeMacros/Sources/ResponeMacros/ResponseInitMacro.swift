import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ResponseInitMacro {}

extension ResponseInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let _ = declaration.as(StructDeclSyntax.self) else {
            throw CustomError.message("@ResponseInit can only be applied to a struct declarations.")
        }
        
        let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
        return [
            "\(access)var json: JSON",
            "\(access)init(json: JSON) { self.json = json }",
        ]
    }
}

extension ResponseInitMacro: ConformanceMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingConformancesOf decl: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [("JSONResponse", nil)]
    }
}

