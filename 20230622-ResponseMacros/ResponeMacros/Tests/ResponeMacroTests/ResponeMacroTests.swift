import ResponeMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "ResponseInit": ResponseInitMacro.self,
    "ResponseJSON": ResponseJSONMacro.self,
]

final class ResponseMacroTests: XCTestCase {
    func testInjectionModule() {
        assertMacroExpansion(
            #"""
            @ResponseJSON(key: "hello") var title: String
            """#,
            expandedSource: #"""
            var title: String {
                get {
                  json["hello"].stringValue
                }
            }
            """#,
            macros: testMacros
        )
    }
    
    func testAPIResponse2() {
        assertMacroExpansion(
            #"""
            @ResponseInit
            public struct Response {
              @ResponseJSON(key: "hello")
              var title: String
            }
            """#,
            expandedSource: #"""

            public struct Response {
              var title: String {
                  get {
                    json["hello"].stringValue
                  }
              }
              public var json: JSON
              public init(json: JSON) {
                  self.json = json
              }
            }
            """#,
            macros: testMacros
        )
    }
}
