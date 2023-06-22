@attached(member,
          names: named(init),
          named(json))
@attached(conformance)
public macro ResponseInit() = #externalMacro(module: "ResponeMacros", type: "ResponseInitMacro")

@attached(accessor)
public macro ResponseJSON(key: String? = nil) = #externalMacro(module: "ResponeMacros", type: "ResponseJSONMacro")
