//
//  AuthServiceKey.swift
//  FeatureAuthInterface
//
//  Created by minsOne on 2022/08/01.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation
import DIContainer

public struct AuthServiceKey: InjectionKey {
    public var type: AuthServiceInterface?
}
