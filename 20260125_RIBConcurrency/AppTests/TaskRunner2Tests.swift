@testable import App
import Foundation
import Testing

@Suite("TaskRunner2 (MainActor/Void) Tests")
@MainActor
struct TaskRunner2Tests {
    // MARK: - 1. Exclusive Execution

    @Test("runExclusive: 작업이 진행 중일 때 추가 호출은 무시되어야 함")
    func runExclusiveBlocking() async throws {
        let sut = TaskRunner2<String>()
        let id = "exclusive_2"

        try await confirmation("작업은 단 한 번만 실행됨", expectedCount: 1) { executed in
            let started1 = sut.runExclusive(id: id) {
                executed()
                try? await Task.sleep(nanoseconds: 200_000_000)
            }

            // 작업이 큐에 쌓이도록 비동기 양보
            try await Task.sleep(nanoseconds: 50_000_000)

            let started2 = sut.runExclusive(id: id) {
                Issue.record("이 작업은 실행되면 안 됩니다")
            }

            #expect(started1 == true)
            #expect(started2 == false)
        }
    }

    @Test("runExclusive: 작업이 완료된 후에는 다시 실행이 가능해야 함")
    func runExclusiveRerun() async throws {
        let sut = TaskRunner2<String>()
        let id = "cleanup_2"

        sut.runExclusive(id: id) {}

        // Cleanup 완료 대기
        try await Task.sleep(nanoseconds: 50_000_000)

        let startedAgain = sut.runExclusive(id: id) {}
        #expect(startedAgain == true)
    }

    // MARK: - 2. Restart Execution

    @Test("runRestart: 새로운 작업이 들어오면 기존 작업은 취소되어야 함")
    func runRestartReplacement() async throws {
        let sut = TaskRunner2<String>()
        let id = "restart_2"

        try await confirmation("두 번째 작업이 성공적으로 실행됨") { secondFinished in
            sut.runRestart(id: id) {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if Task.isCancelled { return }
                Issue.record("첫 번째 작업이 취소되지 않았습니다")
            }

            // 첫 번째 작업이 시작될 기회를 줌
            try await Task.sleep(nanoseconds: 50_000_000)

            sut.runRestart(id: id) {
                secondFinished()
            }

            // 두 번째 작업이 실행될 기회를 줌
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - 3. Cancellation

    @Test("cancel: 특정 ID의 작업을 수동으로 중단하고 다시 실행할 수 있어야 함")
    func manualCancel() async throws {
        let sut = TaskRunner2<String>()
        let id = "cancel_2"

        sut.runExclusive(id: id) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }

        try await Task.sleep(nanoseconds: 10_000_000)
        sut.cancel(id: id)

        // 취소 후에는 즉시 다시 실행 가능해야 함
        let startedAgain = sut.runExclusive(id: id) {}
        #expect(startedAgain == true)
    }

    @Test("cancelAll: 모든 작업을 중단하고 초기화해야 함")
    func cancelAllTasks() async throws {
        let sut = TaskRunner2<String>()

        sut.runExclusive(id: "1") { try? await Task.sleep(nanoseconds: 1_000_000_000) }
        sut.runExclusive(id: "2") { try? await Task.sleep(nanoseconds: 1_000_000_000) }

        try await Task.sleep(nanoseconds: 10_000_000)
        sut.cancelAll()

        let started1 = sut.runExclusive(id: "1") {}
        let started2 = sut.runExclusive(id: "2") {}

        #expect(started1 == true)
        #expect(started2 == true)
    }
}
