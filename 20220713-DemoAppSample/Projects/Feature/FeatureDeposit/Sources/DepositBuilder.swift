//
//  DepositBuilder.swift
//  FeatureDeposit
//
//  Created by minsOne on 2022/07/27.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation
import FeatureAuthInterface
import DIContainer

public protocol DepositBuildable {
    func build1() -> DepositServiceProtocol
    func build3() -> DepositServiceProtocol
}

public struct DepositBuilder: DepositBuildable {
    @Inject1
    var authService1: AuthServiceInterface

    @Inject3(AuthServiceKey.self)
    var authService3: AuthServiceInterface
    
    public init() {}
    
    public func build1() -> DepositServiceProtocol {
        DepositService(authService: authService1)
    }
    
    public func build3() -> DepositServiceProtocol {
        DepositService(authService: authService3)
    }
}
