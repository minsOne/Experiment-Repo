import UIKit

class DismissDisappearReportingViewController: UIViewController {
    enum ActualDisappearReason: String {
        case interactiveTransitionCancelled = "interactive transition canceled"
        case beingDismissed = "isBeingDismissed == true"
        case movingFromParent = "isMovingFromParent == true"
        case detachedFromWindowAndNoActiveContainer = "view.window == nil && not owned by active container"
        case ownedByActiveContainer = "still has active container"
    }

    struct ActualDisappearCheck {
        let isActualDisappear: Bool
        let reason: ActualDisappearReason
    }

    /// 하위 클래스에서 공통으로 사용할 판별 API.
    /// - Returns: 실제 화면에서 제거되었는지와 사유.
    func checkActualDisappear() -> ActualDisappearCheck {
        if let transitionCoordinator,
           transitionCoordinator.isInteractive,
           transitionCoordinator.isCancelled {
            return ActualDisappearCheck(
                isActualDisappear: false,
                reason: .interactiveTransitionCancelled
            )
        }

        if isBeingDismissed {
            return ActualDisappearCheck(isActualDisappear: true, reason: .beingDismissed)
        }

        if isMovingFromParent {
            return ActualDisappearCheck(isActualDisappear: true, reason: .movingFromParent)
        }

        if view.window == nil && !isOwnedByActiveContainer() {
            return ActualDisappearCheck(
                isActualDisappear: true,
                reason: .detachedFromWindowAndNoActiveContainer
            )
        }

        return ActualDisappearCheck(isActualDisappear: false, reason: .ownedByActiveContainer)
    }

    /// VC가 여전히 활성 컨테이너 트리에 소유되어 있는지 판별.
    /// 하위 클래스에서 이 값을 추가 조건으로 조합해 사용할 수 있음.
    func isOwnedByActiveContainer() -> Bool {
        guard !isBeingDismissed && !isMovingFromParent else { return false }

        if let nav = navigationController,
           !nav.isBeingDismissed,
           nav.view.window != nil,
           nav.viewControllers.contains(self) {
            return true
        }

        if let parent = parent,
           parent.view.window != nil,
           parent !== self {
            return true
        }

        if let presenter = presentingViewController,
           presenter.view.window != nil,
           !presenter.isBeingDismissed {
            return true
        }

        return false
    }

    func makeDisappearEventName() -> String {
        "viewDidDisappear"
    }

    /// 하위 클래스가 판별 결과를 기준으로 직접 로그/알림을 결정할 수 있도록 노출.
    /// 현재 기본 동작은 실제 제거로 판단될 때만 로그를 남긴다.
    func logDisappearEventIfNeeded(_ check: ActualDisappearCheck, event: String = "viewDidDisappear") {
        guard check.isActualDisappear else { return }
        DismissProbeLifecycleLogger.shared.log(
            DismissProbeLifecycleLogger.shared.event(from: self, event: event)
        )
    }
}
