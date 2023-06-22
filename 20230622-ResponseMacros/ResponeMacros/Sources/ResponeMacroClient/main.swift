import ResponeMacro
import SwiftyJSON

public protocol JSONResponse {
    var json: JSON { get }
    init(json: JSON)
}

@ResponseInit
public struct SomeResponse {
    @ResponseJSON(key: "_title")
    public var title: String
    @ResponseJSON
    public var msg: String
    @ResponseJSON(key: "yyyy_mm")
    public var yearMonth: String
}

let dict = """
{"_title": "Hello", "msg": "World", "yyyy_mm": "2023"}
"""
let aa = SomeResponse(json: JSON(parseJSON: dict))
print(aa.title)
print(aa.msg)
print(aa.yearMonth)

let bb: some JSONResponse = aa
