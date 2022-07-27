//
//  Container.swift
//  DIContainer
//
//  Created by minsOne on 2022/07/27.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation

public protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get }
}

public extension InjectionKey {
    static var currentValue: Value {
        return Container.root.resolve(for: Self.self)
    }
}

public protocol InjectionType {}

/// A type that contributes to the object graph.
public struct Component {
    fileprivate let name: String
    fileprivate let resolve: () -> InjectionType

    public init<T: InjectionKey>(_ name: T.Type, _ resolve: @escaping () -> InjectionType) {
        self.name = String(describing: name)
        self.resolve = resolve
    }
}

public class Container {
    /// Stored object instance factories.
    private var modules: [String: Component] = [:]
    
    public init() {}
    deinit { modules.removeAll() }
    
    /// Registers a specific type and its instantiating factory.
    public func add(module: Component) {
        modules[module.name] = module
    }
    
    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    public func resolve<T>(for type: Any.Type?) -> T {
        let name = type.map { String(describing: $0) } ?? String(describing: T.self)

        guard let component: T = modules[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }

        return component
    }
    
    public static var root = Container()
    
    /// Construct dependency resolutions.
    public convenience init(@ContainerBuilder _ modules: () -> [Component]) {
        self.init()
        modules().forEach { add(module: $0) }
    }

    /// Construct dependency resolution.
    public convenience init(@ContainerBuilder _ module: () -> Component) {
        self.init()
        add(module: module())
    }

    /// Assigns the current container to the composition root.
    public func build() {
        // Used later in property wrapper
        Self.root = self
    }

    /// DSL for declaring modules within the container dependency initializer.
    @resultBuilder public struct ContainerBuilder {
        public static func buildBlock(_ modules: Component...) -> [Component] { modules }
        public static func buildBlock(_ module: Component) -> Component { module }
    }
}

@propertyWrapper
public class Inject3<Value> {
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
