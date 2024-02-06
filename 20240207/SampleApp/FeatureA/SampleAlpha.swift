//
//  SampleAlpha.swift
//  FeatureA
//
//  Created by minsOne on 2/6/24.
//

import Foundation

package class SampleAlpha {
    package init() {
        print("init \(Self.self)")
    }
    
    package func sampleFunc() {
        print("call \(#function)")
    }
}
