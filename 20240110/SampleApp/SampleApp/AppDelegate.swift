//
//  AppDelegate.swift
//  SampleApp
//
//  Created by minsOne on 1/11/24.
//

import UIKit
import MyMacro

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        runMacro()
        
        return true
    }
}

func runMacro() {
    let a = 17
    let b = 25
    
    let (result, code) = #stringify(a + b)
    
    print("The value \(result) was produced by the code \"\(code)\"")
}
