import Foundation
import DIContainer

public struct AuthResult {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

public protocol AuthServiceInterface {
    func auth() -> AuthResult
}



public struct AuthServiceKey: InjectionKey {
    public typealias Value = AuthServiceInterface
    
    public static var currentValue: Value {
        return Container.root.resolve(for: Self.self)
    }
}


