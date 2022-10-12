//
//  AuthServiceFactory.swift
//  FeatureAuthInterface
//
//  Created by minsOne on 2022/07/27.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation
import DIContainer

public protocol AuthServiceFactoryInterface {
    func build() -> AuthServiceInterface
}

public struct AuthServiceFactory: Injectable {
    private let factory: AuthServiceFactoryInterface

    public init(factory: AuthServiceFactoryInterface) {
        self.factory = factory
    }
    public func build() -> AuthServiceInterface {
        factory.build()
    }
}
