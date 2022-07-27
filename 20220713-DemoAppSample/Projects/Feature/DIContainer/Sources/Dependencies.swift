//
//  Container.swift
//  DIContainer
//
//  Created by minsOne on 2022/07/27.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation

public protocol Injectable {}

/// A type that contributes to the object graph.
public struct Module {
    fileprivate let name: String
    fileprivate let resolve: () -> Injectable

    public init(_ name: Any.Type, _ resolve: @escaping () -> Injectable) {
        self.name = String(describing: name)
        self.resolve = resolve
    }
}



/// A dependency collection that provides resolutions for object instances.
public class Dependencies {
    /// Stored object instance factories.
    private var modules: [String: Module] = [:]

    public init() {}
    deinit { modules.removeAll() }
}

extension Dependencies {

    /// Registers a specific type and its instantiating factory.
    public func add(module: Module) {
        modules[module.name] = module
    }

    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    public func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)

        guard let component: T = modules[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }

        return component
    }

    /// Composition root container of dependencies.
    public static var root = Dependencies()

    /// Construct dependency resolutions.
    public convenience init(@ModuleBuilder _ modules: () -> [Module]) {
        self.init()
        modules().forEach { add(module: $0) }
    }

    /// Construct dependency resolution.
    public convenience init(@ModuleBuilder _ module: () -> Module) {
        self.init()
        add(module: module())
    }

    /// Assigns the current container to the composition root.
    public func build() {
        // Used later in property wrapper
        Self.root = self
    }

    /// DSL for declaring modules within the container dependency initializer.
    @resultBuilder struct ModuleBuilder {
        public static func buildBlock(_ modules: Module...) -> [Module] { modules }
        public static func buildBlock(_ module: Module) -> Module { module }
    }
}

@propertyWrapper
public class Inject1<Value> {
    private let name: String?
    private var storage: Value?

    public var wrappedValue: Value {
        storage ?? {
            let value: Value = Dependencies.root.resolve(for: name)
            storage = value // Reuse instance for later
            return value
        }()
    }

    public init() {
        self.name = nil
    }

    public init(_ name: String) {
        self.name = name
    }
}
