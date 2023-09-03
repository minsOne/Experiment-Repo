//
//  AccountRouter.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/29.
//

import RIBs

protocol AccountInteractable: Interactable {
    var router: AccountRouting? { get set }
    var listener: AccountListener? { get set }
}

protocol AccountViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AccountRouter: ViewableRouter<AccountInteractable, AccountViewControllable>, AccountRouting {
    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: AccountInteractable, viewController: AccountViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
