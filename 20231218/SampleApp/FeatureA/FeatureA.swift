//
//  FeatureA.swift
//  FeatureA
//
//  Created by minsOne on 12/24/23.
//

import Foundation
import MacroKit

public struct ServiceA {
    public static func run() {
        let a = 17
        let b = 25
        
        let (result, code) = #stringify(a + b)
        
        print(#file, "The value \(result) was produced by the code \"\(code)\"")
    }
}
