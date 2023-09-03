//
//  HomeInteractor.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/18.
//

import RIBs
import RxSwift

protocol HomeRouting: ViewableRouting {}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    func update(state: HomeViewState)
}

protocol HomeListener: AnyObject {}

final class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
    weak var router: HomeRouting?
    weak var listener: HomeListener?

    override init(presenter: HomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func request(action: HomeViewAction) {
        let state: HomeViewState
        switch action {
        case .viewDidLoad:
            state = .init(title: "ViewDidLoad Action",
                          desc: "Number \(Int.random(in: 0 ... 5))")
        case .tap1:
            state = .init(title: "Tap1 Action",
                          desc: "Tap1 Number \(Int.random(in: 0 ... 5))")
        case .tap2:
            state = .init(title: "Tap2 Action",
                          desc: "Tap2 Number \(Int.random(in: 0 ... 5))")
        }
        presenter.update(state: state)
    }
}
