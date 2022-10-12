//
//  RegisterContainerService.swift
//  FeatureDemandDepositPackage
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import DIContainer
import FeatureDemandDepositInterface
import FeatureDemandDepositUI
import FeatureDemandDepositDomain


public struct RootComponentFactoryImpl: RootComponentFactory {
    public init() {}
    public func makePresenter() -> RootPresentable & RootViewControllable {
        return RootViewController()
    }
    
    public func makeBuilder(dependency: RootDependency) -> RootBuildable {
        RootBuilder(dependency: dependency)
    }
}
