//
//  ViewController.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/16.
//

import RIBs
import SwiftUI
import UIKit

class ViewController: UIViewController, HomeListener {
    var router: Routing?

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton()
        button.setTitle("Route to HomeView", for: .normal)
        button.contentEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
        button.sizeToFit()
        button.frame.origin = .init(x: 100, y: 200)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        if #available(iOS 14.0, *) {
            button.addAction(.init(handler: { [weak self] _ in
                self?.showHomeView()
            }), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(showHomeView), for: .touchUpInside)
        }
        
        
        view.addSubview(button)
        view.backgroundColor = .systemBlue
    }

    @objc func showHomeView() {
        let router = HomeBuilder().build(withListener: self)
        self.router = router
        router.interactable.activate()
        router.load()
        let vc = router.viewControllable.uiviewController
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
}
