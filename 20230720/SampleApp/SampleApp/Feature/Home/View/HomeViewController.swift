//
//  HomeViewController.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/18.
//

import SwiftUI
import UIKit

protocol HomePresentableListener: AnyObject {
    func request(action: HomeViewAction)
}

final class HomeViewController: UIViewController {
    weak var listener: HomePresentableListener?

    lazy var viewModel = HomeViewModel(listener: listener, state: .init(title: "Hello", desc: "World"))

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Hello World"

        HomeView(viewModel: viewModel)
            .attachTo(ViewController: self)

        listener?.request(action: .viewDidLoad)
    }

    public func update(state: HomeViewState) {
        viewModel.update(state: state)
    }
}

extension View {
    func attachTo(ViewController parentViewController: UIViewController) {
        let contentVC = UIHostingController(rootView: self)
        let parentVC = parentViewController

        parentVC.addChild(contentVC)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        parentVC.view.addSubview(contentVC.view)
        contentVC.didMove(toParent: parentVC)

        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
        ])
    }
}

extension UIViewController {
    func attach(view: some View) {
        let contentVC = UIHostingController(rootView: view)
        let parentVC = self

        parentVC.addChild(contentVC)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        parentVC.view.addSubview(contentVC.view)
        contentVC.didMove(toParent: parentVC)

        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
        ])
    }
}

/// https://speakerdeck.com/kuritatu18/uikit-besunoda-gui-mo-napuroziekutoheno-swiftui-dao-ru?slide=30
