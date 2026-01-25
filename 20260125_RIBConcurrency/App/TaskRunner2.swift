//
//  TaskRunner2.swift
//  App
//
//  Created by 안정민 on 1/26/26.
//

import Combine
import SwiftUI

/// 작업(Task)을 안전하게 관리하고 중복 실행을 방지하는 매니저
/// - Note: ViewModel 등 @MainActor 환경에서 사용해야 합니다.
@MainActor
final class TaskRunner2<Key: Hashable> {
    // 작업 본체와 '고유 실행 ID'를 함께 저장하는 구조체
    private struct TaskInfo {
        let task: Task<Void, Never>
        let executionID: UUID // 작업의 고유 신분증
    }

    // 키별로 진행 중인 작업을 저장
    private var tasks: [Key: TaskInfo] = [:]

    // MARK: - 1. 중복 방지 (Exclusive)

    /// 이미 실행 중인 작업이 있으면 새로운 요청을 '무시'합니다.
    /// - Returns: 작업 시작 여부 (false면 이미 작업 중이라 무시된 것)
    @discardableResult
    func runExclusive(id: Key, operation: @escaping () async -> Void) -> Bool {
        // 이미 작업이 존재하면 무시
        if tasks[id] != nil {
            print("⚠️ [TaskRunner] '\(id)' 작업이 이미 진행 중이라 요청이 무시되었습니다.")
            return false
        }

        startTask(id: id, operation: operation)
        return true
    }

    // MARK: - 2. 최신 작업 유지 (Restart/Debounce)

    /// 기존 작업을 '취소'하고 새로운 작업을 즉시 시작합니다.
    func runRestart(id: Key, operation: @escaping () async -> Void) {
        // 기존 작업 취소
        tasks[id]?.task.cancel()

        // 새 작업 시작
        startTask(id: id, operation: operation)
    }

    // MARK: - 3. 내부 실행 로직 (Core Logic)

    private func startTask(id: Key, operation: @escaping () async -> Void) {
        let executionID = UUID() // 이번 실행을 위한 고유 신분증 발급

        let task = Task {
            // 작업 종료 시 정리 로직 (defer는 스코프 종료 시 무조건 실행됨)
            defer {
                // 🚨 중요: 내가 현재 딕셔너리에 등록된 그 작업일 때만 nil로 지운다.
                // (이미 다른 작업(Restart된 작업)이 자리를 차지했다면 건드리지 않음)
                cleanup(id: id, executionID: executionID)
            }

            await operation()
        }

        // 딕셔너리에 저장
        tasks[id] = TaskInfo(task: task, executionID: executionID)
    }

    // 안전한 정리 함수
    private func cleanup(id: Key, executionID: UUID) {
        // 현재 딕셔너리에 있는 작업의 ID와, 지금 끝난 작업의 ID가 같을 때만 삭제
        if let currentInfo = tasks[id], currentInfo.executionID == executionID {
            tasks[id] = nil
        }
    }

    // MARK: - 4. 관리 기능

    /// 특정 작업 수동 취소
    func cancel(id: Key) {
        tasks[id]?.task.cancel()
        tasks[id] = nil
    }

    /// 모든 작업 취소 (화면 이탈 시 등)
    func cancelAll() {
        tasks.values.forEach { $0.task.cancel() }
        tasks.removeAll()
    }

    deinit {
        // 클래스가 메모리에서 해제될 때 모든 작업 취소
        // 주의: deinit은 MainActor 보장이 안 될 수 있으므로,
        // 딕셔너리에 직접 접근하기보다 캡처된 Task들을 취소하는 것이 안전하나,
        // Swift 6 이전까지는 이 방식이 통용됩니다.
        // 가장 안전한 방법은 tasks를 값을 복사해서 취소하는 것입니다.
        let runningTasks = tasks.values.map(\.task)
        for task in runningTasks {
            task.cancel()
        }
        print("🗑️ [TaskRunner] Deinit: 모든 잔여 작업이 취소되었습니다.")
    }
}
