import Foundation

final nonisolated class TaskRunner<Key: Hashable>: @unchecked Sendable {
    private struct TaskEntry {
        let task: Any // 실제 Task<T, Error> 인스턴스
        private let cancelBlock: @Sendable () -> Void
        let executionID: UUID

        init<T>(task: Task<T, Error>, executionID: UUID) {
            self.task = task
            self.executionID = executionID
            self.cancelBlock = { task.cancel() }
        }

        func cancel() {
            cancelBlock()
        }
    }

    private let lock = NSRecursiveLock()
    private var tasks: [Key: TaskEntry] = [:]

    init() {}

    // MARK: - 1. 중복 방지 (Exclusive)

    @discardableResult
    func runExclusive<T>(id: Key, operation: @escaping @Sendable () async throws -> T) -> Task<T, Error> {
        lock.lock()
        defer { lock.unlock() }

        if let entry = tasks[id] {
            // ✅ 기존 작업이 있으면 해당 작업의 결과를 기다리는 Task 반환
            // 이 Task가 취소되면 실제 원본 Task(entry.task)도 취소되도록 연결
            let existingTask = entry.task
            return Task<T, Error> {
               try await withTaskCancellationHandler {
                    guard let task = existingTask as? Task<T, Error> else {
                        throw NSError(domain: "TaskRunner", code: -1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
                    }
                    return try await task.value
                } onCancel: {
                    // 래퍼 Task가 취소되면 원본 Task도 취소시킴
                    (existingTask as? Task<T, Error>)?.cancel()
                }
            }
        }

        return startTask(id: id, operation: operation)
    }

    // MARK: - 2. 최신 작업 유지 (Restart)

    @discardableResult
    func runRestart<T>(id: Key, operation: @escaping @Sendable () async throws -> T) -> Task<T, Error> {
        lock.lock()
        tasks[id]?.cancel() // ✅ 실제 Task 취소
        tasks[id] = nil
        lock.unlock()

        return startTask(id: id, operation: operation)
    }

    // MARK: - 3. 내부 핵심 로직

    private func startTask<T>(id: Key, operation: @escaping @Sendable () async throws -> T) -> Task<T, Error> {
        let executionID = UUID()

        let newTask = Task<T, Error> {
            defer {
                cleanup(id: id, executionID: executionID)
            }
            return try await operation()
        }

        lock.lock()
        tasks[id] = TaskEntry(task: newTask, executionID: executionID)
        lock.unlock()

        return newTask
    }

    private func cleanup(id: Key, executionID: UUID) {
        lock.lock()
        defer { lock.unlock() }

        if let currentEntry = tasks[id], currentEntry.executionID == executionID {
            tasks[id] = nil
        }
    }

    // MARK: - 4. 수동 제어

    func cancel(id: Key) {
        lock.lock()
        tasks[id]?.cancel() // ✅ 실제 Task 취소
        tasks[id] = nil
        lock.unlock()
    }

    func cancelAll() {
        lock.lock()
        let allEntries = tasks.values
        tasks.removeAll()
        lock.unlock()

        allEntries.forEach { $0.cancel() }
    }

    deinit {
        lock.lock()
        let allEntries = tasks.values
        tasks.removeAll()
        lock.unlock()

        allEntries.forEach { $0.cancel() }
    }
}
