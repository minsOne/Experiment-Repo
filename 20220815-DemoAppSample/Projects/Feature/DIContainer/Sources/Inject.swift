//
//  Inject.swift
//  DIContainer
//
//  Created by minsOne on 2022/08/03.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation

@propertyWrapper
public class Inject<Value> {
    private let lazyValue: (() -> Value)
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = lazyValue()
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init<K>(_ key: K.Type) where K : InjectionKey, Value == K.Value {
        lazyValue = {
            key.currentValue
        }
    }
}
