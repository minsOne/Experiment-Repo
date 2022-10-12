//
//  RootViewController.swift
//  FeatureDemandDepositUI
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import RIBs
import RxSwift
import UIKit
import FeatureDemandDepositInterface

public final class RootViewController: UIViewController, RootPresentable, RootViewControllable {
    public func update(state: FeatureDemandDepositInterface.RootPresentState) {
        
    }
    

    public weak var listener: RootPresentableListener?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemRed
    }
}
