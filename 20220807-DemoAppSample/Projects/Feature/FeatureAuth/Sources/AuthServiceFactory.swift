//
//  AuthServiceFactory.swift
//  FeatureAuth
//
//  Created by minsOne on 2022/07/27.
//  Copyright © 2022 minsone. All rights reserved.
//

import FeatureAuthInterface

public struct AuthServiceFactoryImpl: AuthServiceFactoryInterface {
    public init() {}

    public func build() -> AuthServiceInterface {
        AuthService()
    }
}
