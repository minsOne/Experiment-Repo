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

protocol Routing {}

/// ModuleName : 입출금통장Interface
/// FileName : 입출금통장Buildable.swift

protocol 입출금통장Listener {}

protocol 입출금통장Buildable {
    init()
    func build(_ listener: 입출금통장Listener) -> Routing
}
