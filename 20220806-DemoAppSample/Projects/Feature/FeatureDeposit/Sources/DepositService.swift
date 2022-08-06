import FeatureAuthInterface

public protocol DepositServiceProtocol {
    func run()
}

public struct DepositService: DepositServiceProtocol {
    let authService: AuthServiceInterface

    public init(authService: AuthServiceInterface) {
        self.authService = authService
    }

    public func run() {
        let result = authService.auth()
        print("Auth Result : \(result.value)")
    }
}
