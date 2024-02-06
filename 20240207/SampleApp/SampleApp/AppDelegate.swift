//
//  AppDelegate.swift
//  SampleApp
//
//  Created by minsOne on 2/6/24.
//

import UIKit
import FeatureA
import FeatureB

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func run() {
        SampleAlpha().sampleFunc()
        SampleBeta().sampleFunc()
    }
}

