//
//  R.swift
//  AppResources
//
//  Created by minsOne on 2023/04/17.
//

import Foundation
import UIKit

public class R {
    public enum Storyboard {}
}

public extension R.Storyboard {
    static var BViewController: UIStoryboard {
        UIStoryboard(name: "BViewController", bundle: Bundle(for: R.self))
    }
}

@_spi(Hello)
public struct AAAA {}
