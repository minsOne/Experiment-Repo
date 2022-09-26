import Foundation
import DIContainer

public struct PinResult {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }
}

public protocol PinServiceInterface {
    func auth() -> PinResult
}
