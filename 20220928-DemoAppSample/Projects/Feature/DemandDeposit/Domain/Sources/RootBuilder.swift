//
//  RootBuilder.swift
//  FeatureDemandDepositDomain
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import RIBs
import FeatureDemandDepositInterface
import DIContainer

final class RootComponent: RIBs.Component<RootDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}


public final class RootBuilder: Builder<RootDependency>, RootBuildable {

    public override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: RootListener) -> RootRouting {
        let component = RootComponent(dependency: dependency)
        
        @Inject(RootComponentFactoryKey.self)
        var factory: RootComponentFactoryKey.Value
        
        let presenter = factory.makePresenter()
        
        let interactor = RootInteractor(presenter: presenter)
        interactor.listener = listener
        return RootRouter(interactor: interactor, viewController: presenter)
    }
}
