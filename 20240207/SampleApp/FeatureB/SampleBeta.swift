//
//  FeatureB.swift
//  FeatureB
//
//  Created by minsOne on 2/6/24.
//

import Foundation

package class SampleBeta {
    package init() {
        print("init \(Self.self)")
    }

    package func sampleFunc() {
        print("call \(#function)")
    }
}
