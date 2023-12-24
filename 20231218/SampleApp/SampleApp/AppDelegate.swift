//
//  AppDelegate.swift
//  SampleApp
//
//  Created by minsOne on 12/24/23.
//

import UIKit
import FeatureA
import MacroKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        run()

        ServiceA.run()
        
        return true
    }

    func run() {
        let a = 17
        let b = 25
        
        let (result, code) = #stringify(a + b)
        
        print(#file, "The value \(result) was produced by the code \"\(code)\"")
    }
}
