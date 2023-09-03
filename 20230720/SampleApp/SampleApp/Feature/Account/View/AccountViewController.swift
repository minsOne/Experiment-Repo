//
//  AccountViewController.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/29.
//

import RIBs
import UIKit

protocol AccountPresentableListener: AnyObject {
    func request(action: AccountViewAction)
}

final class AccountViewController: UIViewController {
    weak var listener: AccountPresentableListener?
    
    lazy var viewModel = AccountViewModel(listener: listener,
                                          state: .init())

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account"

        AccountView(viewModel: viewModel)
            .attachTo(ViewController: self)

        listener?.request(action: .viewDidLoad)
    }
}
