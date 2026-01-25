import Combine

public struct RIBResult<T> {
    private let publisher: AnyPublisher<T, Never>

    public init<P: Publisher>(_ publisher: P) where P.Output == T, P.Failure == Never {
        self.publisher = publisher.first().eraseToAnyPublisher()
    }

    public var asyncValue: T {
        get async {
            await publisher.values.first(where: { _ in true })!
        }
    }
}
