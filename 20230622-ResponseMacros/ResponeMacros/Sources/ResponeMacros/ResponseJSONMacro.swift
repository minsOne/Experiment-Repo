import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ResponseJSONMacro {}

extension ResponseJSONMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = binding.typeAnnotation?.type,
              binding.accessor == nil
        else {
            return []
        }
        
        var key = identifier.text
        
        if case let .argumentList(arguments) = node.argument,
           let expression = arguments.first?.expression,
           let stringSegment = expression.as(StringLiteralExprSyntax.self)?.segments.first,
           case let .stringSegment(manualKey) = stringSegment {
            key = manualKey.content.text
        }
        
        let typeDesc = type.as(SimpleTypeIdentifierSyntax.self)?.description
        let jsonValueText: String = switch typeDesc {
        case "String": ".stringValue"
        case "Int": ".intValue"
        default: ""
        }
        let getAccessor: AccessorDeclSyntax =
      """
      get {
        json[\(literal: key)]\(raw: jsonValueText)
      }
      """
        
        return [getAccessor]
    }
}
