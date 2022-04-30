//
//  SampleServiceInteractor.swift
//  SampleFramework
//
//  Created by minsOne on 2022/01/30.
//

import RIBs
import RxSwift

protocol SampleServiceRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol SampleServicePresentable: Presentable {
    var listener: SampleServicePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol SampleServiceListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class SampleServiceInteractor: PresentableInteractor<SampleServicePresentable>, SampleServiceInteractable, SampleServicePresentableListener {

    weak var router: SampleServiceRouting?
    weak var listener: SampleServiceListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: SampleServicePresentable) {
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
}
