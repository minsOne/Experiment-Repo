//
//  SampleServiceRouter.swift
//  SampleFramework
//
//  Created by minsOne on 2022/01/30.
//

import RIBs

protocol SampleServiceInteractable: Interactable {
    var router: SampleServiceRouting? { get set }
    var listener: SampleServiceListener? { get set }
}

protocol SampleServiceViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class SampleServiceRouter: ViewableRouter<SampleServiceInteractable, SampleServiceViewControllable>, SampleServiceRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: SampleServiceInteractable, viewController: SampleServiceViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
