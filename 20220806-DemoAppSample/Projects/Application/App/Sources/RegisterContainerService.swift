//
//  RegisterContainerService.swift
//  Application
//
//  Created by minsOne on 2022/08/06.
//  Copyright © 2022 minsone. All rights reserved.
//

import DIContainer
import FeatureAuthInterface
import FeatureAuth

struct ContainerRegisterService {
    func register() {
        let container = Container {
            Component(FeatureAuthInterface.AuthServiceKey.self) { FeatureAuth.AuthService() }
        }
        container.build()
    }
}
