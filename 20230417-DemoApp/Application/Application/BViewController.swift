//
//  BViewController.swift
//  Application
//
//  Created by minsOne on 2023/04/17.
//

import Foundation
import UIKit

class BViewController: UIViewController {
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }
}
