//
//  AccountInteractor.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/29.
//

import RIBs
import RxSwift

protocol AccountRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol AccountPresentable: Presentable {
    var listener: AccountPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol AccountListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class AccountInteractor: PresentableInteractor<AccountPresentable>, AccountInteractable, AccountPresentableListener {
    weak var router: AccountRouting?
    weak var listener: AccountListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: AccountPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    func request(action: AccountViewAction) {}
}
