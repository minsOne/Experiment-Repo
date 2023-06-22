import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension DeclModifierSyntax {
    var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
        case .keyword(.public): return true
        default: return false
        }
    }
}

enum CustomError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case let .message(text):
            return text
        }
    }
}

extension SyntaxStringInterpolation {
    // It would be nice for SwiftSyntaxBuilder to provide this out-of-the-box.
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            appendInterpolation(node)
        }
    }
}
