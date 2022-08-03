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
    func build() -> DepositServiceProtocol
}

public struct DepositBuilder: DepositBuildable {
    @Inject(AuthServiceKey.self)
    var authService3: AuthServiceInterface
    
    public init() {}

    public func build() -> DepositServiceProtocol {
        DepositService(authService: authService3)
    }
}
