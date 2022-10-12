import FeatureAuthInterface
import DIContainer

public struct AuthService: AuthServiceInterface {
    public init() {}

    public func auth() -> AuthResult {
        return AuthResult(value: 10)
    }
}
