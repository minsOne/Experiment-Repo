import UIKit

class BaseScenarioViewController: DismissDisappearReportingViewController {
    // MARK: - Appearance customization (subclasses)
    var debugBackgroundColor: UIColor { .systemGray6 }
    var actionButtonTitle: String? { nil }
    var scenarioHint: String { "" }
    var debugPrimaryTextColor: UIColor { .label }
    var debugSecondaryTextColor: UIColor { .secondaryLabel }
    static var actualDisappearEvaluationCounts: [String: Int] = [:]
    static var actualDisappearSuccessCounts: [String: Int] = [:]
    static var actualDisappearRetainCounts: [String: Int] = [:]

    private var hintLabel: UILabel?
    private var evaluationCounter: Int {
        Self.actualDisappearEvaluationCounts[String(describing: type(of: self)), default: 0]
    }

    // MARK: - UI
    override func viewDidLoad() {
        super.viewDidLoad()

        let vcName = String(describing: type(of: self))
        view.backgroundColor = debugBackgroundColor
        title = vcName
        view.accessibilityIdentifier = "\(vcName)-view"

        let nameLabel = UILabel()
        nameLabel.text = vcName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.textColor = debugPrimaryTextColor
        nameLabel.textAlignment = .center
        nameLabel.accessibilityIdentifier = "\(vcName)-nameLabel"

        let hintLabel = UILabel()
        hintLabel.text = scenarioHintWithEvaluationResult(nil)
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.textColor = debugSecondaryTextColor
        hintLabel.accessibilityIdentifier = "\(vcName)-hintLabel"
        self.hintLabel = hintLabel

        let vstack = UIStackView(arrangedSubviews: [nameLabel, hintLabel])
        vstack.axis = .vertical
        vstack.spacing = 12
        vstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vstack)

        if let actionButtonTitle {
            let button = UIButton(type: .system)
            button.setTitle(actionButtonTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.systemBlue
            button.layer.cornerRadius = 12
            button.heightAnchor.constraint(equalToConstant: 52).isActive = true
            button.accessibilityIdentifier = "\(vcName)-action"
            button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
            vstack.addArrangedSubview(button)
            vstack.spacing = 24
            vstack.setCustomSpacing(30, after: hintLabel)
        }

        NSLayoutConstraint.activate([
            vstack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 24),
            vstack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -24)
        ])
    }

    @objc func actionTapped() {
        handlePrimaryAction()
    }

    /// 자식 ViewController가 viewDidDisappear에서 직접 호출해 사용.
    func evaluateActualDisappearAndNotify() -> ActualDisappearCheck {
        let disappearCheck = checkActualDisappear()
        logDisappearEvent(disappearCheck, event: makeDisappearEventName())
        didEvaluateActualDisappear(disappearCheck)
        return disappearCheck
    }

    private func scenarioHintWithEvaluationResult(_ check: ActualDisappearCheck?) -> String {
        guard let check else {
            return scenarioHint + "\n\n[실제 제거 판별] 아직 미판단"
        }

        let state = check.isActualDisappear ? "실제로 제거됨" : "아직 화면에 남아있음(제거되지 않음)"
        return """
        \(scenarioHint)

        [실제 제거 판별] \(state)
        사유: \(check.reason.rawValue)
        누적 판별 횟수: \(evaluationCounter)
        """
    }

    /// Primary action 버튼 동작. 각 시나리오 VC에서 override.
    func handlePrimaryAction() {
        // subclasses override
    }

    /// 자식 VC가 필요 시 진짜 사라짐 판별 결과를 활용해 처리할 수 있는 훅.
    func didEvaluateActualDisappear(_ check: ActualDisappearCheck) {
        let vcName = String(describing: type(of: self))
        Self.actualDisappearEvaluationCounts[vcName, default: 0] += 1
        if check.isActualDisappear {
            Self.actualDisappearSuccessCounts[vcName, default: 0] += 1
        } else {
            Self.actualDisappearRetainCounts[vcName, default: 0] += 1
        }
        hintLabel?.text = scenarioHintWithEvaluationResult(check)
        let evaluationIndex = Self.actualDisappearEvaluationCounts[vcName] ?? 0

        NotificationCenter.default.post(
            name: .scenarioActualDisappearEvaluated,
            object: self,
            userInfo: [
                "vcName": vcName,
                "isActualDisappear": check.isActualDisappear,
                "reason": check.reason.rawValue,
                "index": evaluationIndex
            ]
        )

        if check.isActualDisappear {
            print("[\(String(describing: type(of: self)))] 실제 제거 확인: \(check.reason.rawValue)")
        } else {
            print("[\(String(describing: type(of: self)))] 삭제 아님: \(check.reason.rawValue)")
        }
    }
}

extension Notification.Name {
    static let scenarioActualDisappearEvaluated = Notification.Name("ScenarioActualDisappearEvaluated")
}
