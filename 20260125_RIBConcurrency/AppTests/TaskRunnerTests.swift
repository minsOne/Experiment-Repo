@testable import App
import Foundation
import Testing

@Suite("TaskRunner (Generic/Thread-Safe) Tests")
struct TaskRunnerTests {
    // MARK: - 1. Exclusive Execution

    @Test("runExclusive: 여러번 호출해도 가장 먼저 시작된 동일한 작업을 공유해야 함")
    func runExclusiveSharing() async throws {
        let sut = TaskRunner<String>()
        let id = "exclusive_test"
        let count = ManagedAtomic<Int>(0)

        try await confirmation("작업은 단 한 번만 실행됨", expectedCount: 1) { executed in
            let task1 = sut.runExclusive(id: id) {
                executed()
                try await Task.sleep(nanoseconds: 200_000_000)
                return "Result"
            }

            try await Task.sleep(nanoseconds: 50_000_000)

            let task2 = sut.runExclusive(id: id) {
                count.increment()
                return "New Result"
            }

            let res1 = try await task1.value
            let res2 = try await task2.value

            #expect(res1 == "Result")
            #expect(res2 == "Result") // 동일한 작업을 공유하므로 결과도 같음
            #expect(count.load() == 0) // 두 번째 클로저는 실행되지 않음
        }
    }

    @Test("runExclusive: 작업이 완료된 후에는 새로운 작업을 실행할 수 있어야 함")
    func runExclusiveCleanup() async throws {
        let sut = TaskRunner<String>()
        let id = "cleanup_test"

        let task1 = sut.runExclusive(id: id) { "First" }
        _ = try await task1.value

        // Cleanup(defer) 반영을 위해 미세 지연
        try await Task.sleep(nanoseconds: 10_000_000)

        let task2 = sut.runExclusive(id: id) { "Second" }
        let res2 = try await task2.value

        #expect(res2 == "Second")
    }

    // MARK: - 2. Restart Execution

    @Test("runRestart: 새로운 작업이 시작되면 이전 작업은 즉시 취소되어야 함")
    func runRestartCancellation() async throws {
        let sut = TaskRunner<String>()
        let id = "restart_test"

        let task1 = sut.runRestart(id: id) {
            try await Task.sleep(nanoseconds: 500_000_000)
            return "Old"
        }

        try await Task.sleep(nanoseconds: 50_000_000)

        let task2 = sut.runRestart(id: id) {
            "New"
        }

        #expect(task1.isCancelled == true)
        let res2 = try await task2.value
        #expect(res2 == "New")
    }

    // MARK: - 3. Cancellation

    @Test("cancel: 특정 ID의 작업을 수동으로 중단할 수 있어야 함")
    func manualCancel() async throws {
        let sut = TaskRunner<String>()
        let id = "cancel_test"

        let task = sut.runExclusive(id: id) {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return "Done"
        }

        sut.cancel(id: id)
        #expect(task.isCancelled == true)
    }

    @Test("cancelAll: 관리 중인 모든 작업을 한꺼번에 중단할 수 있어야 함")
    func cancelAllTasks() async throws {
        let sut = TaskRunner<String>()

        let t1 = sut.runExclusive(id: "1") { try await Task.sleep(nanoseconds: 1_000_000_000) }
        let t2 = sut.runExclusive(id: "2") { try await Task.sleep(nanoseconds: 1_000_000_000) }

        sut.cancelAll()

        #expect(t1.isCancelled == true)
        #expect(t2.isCancelled == true)
    }

    // MARK: - 4. Error Handling

    @Test("Error: 작업 중 발생한 에러가 호출부로 정확히 전파되어야 함")
    func errorPropagation() async throws {
        let sut = TaskRunner<String>()
        struct MockError: Error, Equatable {}

        let task = sut.runExclusive(id: "error") {
            throw MockError()
        }

        await #expect(throws: MockError.self) {
            try await task.value
        }
    }
}

// 간단한 원자적 변수 구현 (Swift Testing 환경용)
private final class ManagedAtomic<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: T
    init(_ value: T) { self.value = value }
    func load() -> T { lock.withLock { value } }
    func increment() where T == Int { lock.withLock { value += 1 } }
}

extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
