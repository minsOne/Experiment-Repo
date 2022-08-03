//
//  Inject2.swift
//  DIContainer
//
//  Created by minsOne on 2022/07/30.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation

@propertyWrapper
public class Inject2<Value: Injectable> {
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = Dependencies.resolve()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init() {}
}
