//
//  RootRouter.swift
//  FeatureDemandDepositDomain
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import RIBs
import FeatureDemandDepositInterface

final class RootRouter: ViewableRouter<RootInteractable, RootViewControllable>, RootRouting {
    func requestRoute() {
        
    }
    

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: RootInteractable, viewController: RootViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
