//
//  RootInteractor.swift
//  FeatureDemandDepositDomain
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import RIBs
import RxSwift
import FeatureDemandDepositInterface

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
    func request(action: FeatureDemandDepositInterface.RootAction) {
        
    }
    

    weak var router: RootRouting?
    weak var listener: RootListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        print(#function)
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
