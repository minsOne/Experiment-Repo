import FeatureAuthInterface
import DIContainer

public struct AuthService: AuthServiceInterface, Injectable, InjectionType {
    public init() {}

    public func auth() -> AuthResult {
        return AuthResult(value: 10)
    }
}
