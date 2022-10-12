//
//  InjectionKey.swift
//  DIContainer
//
//  Created by minsOne on 2022/08/03.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation

public protocol InjectionKey {
    associatedtype Value
    var type: Value? { get }
    static var currentValue: Self.Value { get }
}

public extension InjectionKey {
    static var currentValue: Value {
        return Container.resolve(for: Self.self)
    }
}
