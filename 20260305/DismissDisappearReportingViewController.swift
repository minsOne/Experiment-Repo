import UIKit
import DismissProbeValidation

class DismissDisappearReportingViewController: UIViewController {
    typealias ActualDisappearReason = DismissProbeValidation.ActualDisappearReason
    typealias ActualDisappearCheck = DismissProbeValidation.ActualDisappearCheck

    /// 하위 클래스에서 공통으로 사용할 판별 API.
    /// - Returns: 실제 화면에서 제거되었는지와 사유.
    func checkActualDisappear() -> ActualDisappearCheck {
        return ActualDisappearEvaluator.evaluate(self)
    }

    func makeDisappearEventName() -> String {
        "viewDidDisappear"
    }

    /// 하위 클래스가 판별 결과를 기준으로 직접 로그/알림을 결정할 수 있도록 노출.
    /// 현재 기본 동작은 이벤트 자체를 항상 기록한다.
    func logDisappearEvent(_ check: ActualDisappearCheck, event: String = "viewDidDisappear") {
        DismissProbeLifecycleLogger.shared.log(
            DismissProbeLifecycleLogger.shared.event(from: self, event: event)
        )
    }
}
