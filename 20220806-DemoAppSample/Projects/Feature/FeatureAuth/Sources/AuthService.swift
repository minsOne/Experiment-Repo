import FeatureAuthInterface
import DIContainer

public struct AuthService: AuthServiceInterface, Injectable {
    public init() {}

    public func auth() -> AuthResult {
        return AuthResult(value: 10)
    }
}
