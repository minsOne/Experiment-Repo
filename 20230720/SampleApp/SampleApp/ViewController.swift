//
//  ViewController.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/16.
//

import RIBs
import SwiftUI
import UIKit

class ViewController: UIViewController, HomeListener, AccountListener {
    var router: Routing?

    override func viewDidLoad() {
        super.viewDidLoad()

        let button1 = UIButton()
        button1.setTitle("Route to HomeView", for: .normal)
        button1.contentEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
        button1.sizeToFit()
        button1.frame.origin = .init(x: 100, y: 200)
        button1.layer.borderWidth = 2
        button1.layer.borderColor = UIColor.black.cgColor
        if #available(iOS 14.0, *) {
            button1.addAction(.init(handler: { [weak self] _ in
                self?.showHomeView()
            }), for: .touchUpInside)
        } else {
            button1.addTarget(self, action: #selector(showHomeView), for: .touchUpInside)
        }

        view.addSubview(button1)
        
        let button2 = UIButton()
        button2.setTitle("Route to AccountView", for: .normal)
        button2.contentEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
        button2.sizeToFit()
        button2.frame.origin = .init(x: 100, y: 300)
        button2.layer.borderWidth = 2
        button2.layer.borderColor = UIColor.black.cgColor
        if #available(iOS 14.0, *) {
            button2.addAction(.init(handler: { [weak self] _ in
                self?.showAccountView()
            }), for: .touchUpInside)
        } else {
            button2.addTarget(self, action: #selector(showAccountView), for: .touchUpInside)
        }
        
        view.addSubview(button2)
        
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
    
    @objc func showAccountView() {
        let router = AccountBuilder().build(withListener: self)
        self.router = router
        router.interactable.activate()
        router.load()
        let vc = router.viewControllable.uiviewController
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
}
