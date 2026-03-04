import Foundation
import UIKit

struct DismissProbeLifecycleEvent: Codable {
    let timestamp: String
    let vcName: String
    let event: String
    let isBeingDismissed: Bool
    let isMovingFromParent: Bool
    let viewWindowIsNil: Bool
    let hasPresentingVC: Bool
    let hasNavigationController: Bool
}

final class DismissProbeLifecycleLogger {
    static let shared = DismissProbeLifecycleLogger()

    private let logFilePath: String?
    private let queue = DispatchQueue(label: "com.dismissProbe.lifecycleLogger", qos: .utility)
    private let formatter: ISO8601DateFormatter

    private init() {
        logFilePath = ProcessInfo.processInfo.environment["DISMISS_UI_TEST_LOG_PATH"]
        formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    func log(_ event: DismissProbeLifecycleEvent) {
        print("[\(event.vcName)] \(event.event)")
        print("  isBeingDismissed: \(event.isBeingDismissed)")
        print("  isMovingFromParent: \(event.isMovingFromParent)")
        print("  view.window: \(event.viewWindowIsNil ? "nil" : "exists")")
        print("  presentingVC: \(event.hasPresentingVC ? "exists" : "nil")")
        print("  navigationController: \(event.hasNavigationController ? "exists" : "nil")")

        guard let logFilePath else { return }
        appendToFile(event)
    }

    private func appendToFile(_ event: DismissProbeLifecycleEvent) {
        queue.sync {
            let path = self.logFilePath
            guard let path else { return }

            let url = URL(fileURLWithPath: path)
            do {
                if !FileManager.default.fileExists(atPath: path) {
                    FileManager.default.createFile(atPath: path, contents: nil)
                }

                let line = try JSONEncoder().encode(event)
                guard let newLine = String(data: line, encoding: .utf8) else { return }

                let handle = try FileHandle(forWritingTo: url)
                defer { try? handle.close() }
                handle.seekToEndOfFile()
                try handle.write(contentsOf: (newLine + "\n").data(using: .utf8)!)
            } catch {
                print("[DismissProbeLifecycleLogger] 로그 저장 실패: \(error)")
            }
        }
    }

    func event(from viewController: UIViewController, event: String) -> DismissProbeLifecycleEvent {
        return DismissProbeLifecycleEvent(
            timestamp: formatter.string(from: Date()),
            vcName: String(describing: type(of: viewController)),
            event: event,
            isBeingDismissed: viewController.isBeingDismissed,
            isMovingFromParent: viewController.isMovingFromParent,
            viewWindowIsNil: viewController.view.window == nil,
            hasPresentingVC: viewController.presentingViewController != nil,
            hasNavigationController: viewController.navigationController != nil
        )
    }
}
