import UIKit

private typealias DisappearReason = DismissDisappearReportingViewController.ActualDisappearReason

private extension BaseScenarioViewController {
    func reportScenarioEvaluation(
        _ check: ActualDisappearCheck,
        expectedActual: Bool,
        acceptedReasons: Set<DisappearReason>,
        scenarioLabel: String
    ) {
        let isExpected = check.isActualDisappear == expectedActual && acceptedReasons.contains(check.reason)
        let vcName = String(describing: type(of: self))
        let evaluationIndex = Self.actualDisappearEvaluationCounts[vcName] ?? 0
        let status = isExpected ? "PASS" : "DIFF"

        print("[\(scenarioLabel)] \(status): isActual=\(check.isActualDisappear), reason=\(check.reason.rawValue)")

        NotificationCenter.default.post(
            name: .scenarioActualDisappearBranchEvaluated,
            object: self,
            userInfo: [
                "vcName": vcName,
                "scenarioLabel": scenarioLabel,
                "isExpected": isExpected,
                "expectedActual": expectedActual,
                "isActual": check.isActualDisappear,
                "reason": check.reason.rawValue,
                "evaluationIndex": evaluationIndex
            ]
        )
    }
}

final class Scenario1ChildViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemTeal }
    override var actionButtonTitle: String? { "Dismiss" }
    override var scenarioHint: String {
        "present(.pageSheet) 후 Dismiss 버튼을 눌러서 닫아주세요.\n\n[검증] isBeingDismissed == true, view.window == nil"
    }

    override func handlePrimaryAction() {
        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.beingDismissed],
            scenarioLabel: "S1"
        )
    }
}

final class Scenario2ChildViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemGreen }
    override var scenarioHint: String {
        "present(.pageSheet) 후 하단에서 스와이프로 dismiss 하세요.\n\nviewDidDisappear 호출 여부와 view.window == nil 확인"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.beingDismissed, .detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S2"
        )
    }
}

final class Scenario3ChildViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemOrange }
    override var scenarioHint: String {
        "present(.pageSheet) 후 스와이프를 시작하다가 손가락을 올려서 취소하세요.\n\nviewDidDisappear가 호출되면 안 됩니다."
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: false,
            acceptedReasons: [.interactiveTransitionCancelled],
            scenarioLabel: "S3"
        )
    }
}

final class Scenario4ChildViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemPurple }
    override var actionButtonTitle: String? { "Pop" }
    override var scenarioHint: String {
        "NavigationController에서 push된 화면입니다.\n\nPop 버튼 또는 백스와이프/백 버튼으로 pop 후 상태를 확인하세요."
    }

    override func handlePrimaryAction() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.movingFromParent, .detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S4"
        )
    }
}

final class Scenario5AViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemBlue }
    override var scenarioHint: String {
        "NavController 안의 A.\n\n오직 C에서 dismiss 호출 후 A/B/C 로그를 비교하세요."
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S5-A"
        )
    }
}

final class Scenario5BViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemIndigo }
    override var scenarioHint: String {
        "NavController 안의 B.\n\n오직 C에서 dismiss 호출 후 A/B/C 로그를 비교하세요."
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S5-B"
        )
    }
}

final class Scenario5CViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemPink }
    override var actionButtonTitle: String? { "Dismiss Nav" }
    override var scenarioHint: String {
        "NavController 안의 C.\n\nDismiss 버튼으로 전체 NavigationController를 dismiss하세요."
    }

    override func handlePrimaryAction() {
        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S5-C"
        )
    }
}

final class Scenario6AViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemBrown }
    override var scenarioHint: String {
        "popToRoot에서 중간 VC A.\n\npopToRoot 호출 후 로그: isMovingFromParent == false, view.window == nil 기대"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S6-A"
        )
    }
}

final class Scenario6BViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemYellow }
    override var scenarioHint: String {
        "popToRoot에서 중간 VC B.\n\npopToRoot 호출 후 로그: isMovingFromParent == false, view.window == nil 기대"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S6-B"
        )
    }
}

final class Scenario6CViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemRed }
    override var actionButtonTitle: String? { "PopToRoot" }
    override var scenarioHint: String {
        "최상단 VC C.\n\n이 VC에서 PopToRoot를 호출하세요.\n\nexpect isMovingFromParent == true"
    }

    override func handlePrimaryAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.movingFromParent],
            scenarioLabel: "S6-C"
        )
    }
}

final class Scenario7ChildViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemTeal }
    override var actionButtonTitle: String? { "Present Overlay" }
    override var scenarioHint: String {
        "ChildVC 위에 OverlayVC를 present(.overCurrentContext)해 오탐을 검증합니다.\n\nChildVC의 view.window는 dismiss 판단에서 nil이 아니어야 합니다."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        let back = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        back.accessibilityIdentifier = "scenario-7-back-button"
        navigationItem.leftBarButtonItem = back
    }

    override func handlePrimaryAction() {
        let overlay = Scenario7OverlayViewController()
        overlay.modalPresentationStyle = .overCurrentContext
        present(overlay, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: false,
            acceptedReasons: [.ownedByActiveContainer],
            scenarioLabel: "S7-Child"
        )
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

final class Scenario7OverlayViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { UIColor.black.withAlphaComponent(0.35) }
    override var actionButtonTitle: String? { "Dismiss Overlay" }
    override var debugPrimaryTextColor: UIColor { .white }
    override var debugSecondaryTextColor: UIColor { .white.withAlphaComponent(0.9) }
    override var scenarioHint: String {
        "OverlayVC (overCurrentContext).\n\n닫으면 다시 ChildVC로 돌아갑니다."
    }

    override func actionTapped() {
        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.beingDismissed],
            scenarioLabel: "S7-Overlay"
        )
    }
}

final class Scenario8PullScreenViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .systemGray }
    override var actionButtonTitle: String? { "Push Next" }
    override var scenarioHint: String {
        "fullScreen 모달에서 하단으로 pull-down dismiss 하세요.\n\n왼쪽 상단의 X 버튼으로 닫기 가능합니다.\nPush Next로 네비게이션 스택을 늘려주세요."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.accessibilityIdentifier = "scenario8-pullscreen-close"
        navigationItem.leftBarButtonItem = closeButton
    }

    override func handlePrimaryAction() {
        let next = Scenario8PullScreenDetailViewController()
        navigationController?.pushViewController(next, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.beingDismissed, .detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S8"
        )
    }
}

final class Scenario8PullScreenDetailViewController: BaseScenarioViewController {
    override var debugBackgroundColor: UIColor { .darkGray }
    override var scenarioHint: String {
        "시나리오 8 네비게이션 스택의 두 번째 화면.\n\n상단 바의 뒤로가기 또는 pull-down-dismiss로 종료 동작을 확인하세요."
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let check = evaluateActualDisappearAndNotify()
        reportScenarioEvaluation(
            check,
            expectedActual: true,
            acceptedReasons: [.movingFromParent, .detachedFromWindowAndNoActiveContainer],
            scenarioLabel: "S8-Detail"
        )
    }
}

extension Notification.Name {
    static let scenarioActualDisappearBranchEvaluated = Notification.Name("ScenarioActualDisappearBranchEvaluated")
}
