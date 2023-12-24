//
//  Macro.swift
//  MacroKit
//
//  Created by minsOne on 12/24/23.
//

import Foundation

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "MyMacroMacros", type: "StringifyMacro")
