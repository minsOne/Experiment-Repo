import UIKit

final class RootViewController: UIViewController {
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemBackground
        title = "ViewController Dismiss Detection"
        navigationItem.hidesBackButton = true

        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "8가지 시나리오를 실행하고 콘솔 로그를 확인하세요."
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let buttonConfigs: [(String, Selector)] = [
            ("1. 시나리오 1: Modal Dismiss (코드)", #selector(runScenario1)),
            ("2. 시나리오 2: 스와이프 Dismiss (수동 테스트)", #selector(runScenario2)),
            ("3. 시나리오 3: 스와이프 취소 (수동 테스트)", #selector(runScenario3)),
            ("4. 시나리오 4: Navigation Pop", #selector(runScenario4)),
            ("5. 시나리오 5: NavController Modal Dismiss", #selector(runScenario5)),
            ("6. 시나리오 6: popToRootViewController", #selector(runScenario6)),
            ("7. 시나리오 7: 오탐 방지 (위에 VC Present)", #selector(runScenario7)),
            ("8. 시나리오 8: FullScreen Pull Dismiss", #selector(runScenario8))
        ]

        let wrapper = UIStackView(arrangedSubviews: [descriptionLabel, stackView])
        wrapper.axis = .vertical
        wrapper.spacing = 24
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wrapper)

        for (index, config) in buttonConfigs.enumerated() {
            let (title, action) = config
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            button.setTitleColor(.systemBlue, for: .normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.4).cgColor
            button.accessibilityIdentifier = "scenario-\(index + 1)-button"
            button.addTarget(self, action: action, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            wrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            wrapper.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate(stackView.arrangedSubviews.enumerated().map { _, view in
            view.heightAnchor.constraint(equalToConstant: 52)
        })
    }

    @objc private func runScenario1() {
        let vc = Scenario1ChildViewController()
        presentScenarioWithPageSheet(vc)
    }

    @objc private func runScenario2() {
        let vc = Scenario2ChildViewController()
        presentScenarioWithPageSheet(vc)
    }

    @objc private func runScenario3() {
        let vc = Scenario3ChildViewController()
        presentScenarioWithPageSheet(vc)
    }

    @objc private func runScenario4() {
        let vc = Scenario4ChildViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func runScenario5() {
        let a = Scenario5AViewController()
        let b = Scenario5BViewController()
        let c = Scenario5CViewController()

        let nav = UINavigationController()
        nav.modalPresentationStyle = .pageSheet
        nav.setViewControllers([a, b, c], animated: true)
        present(nav, animated: true)
    }

    @objc private func runScenario6() {
        guard let nav = navigationController else { return }

        let a = Scenario6AViewController()
        let b = Scenario6BViewController()
        let c = Scenario6CViewController()
        nav.setViewControllers([self, a, b, c], animated: true)
    }

    @objc private func runScenario7() {
        let vc = Scenario7ChildViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func runScenario8() {
        let vc = Scenario8PullScreenViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.isModalInPresentation = false
        present(nav, animated: true)
    }

    private func presentScenarioWithPageSheet(_ vc: UIViewController) {
        vc.modalPresentationStyle = .pageSheet
        vc.isModalInPresentation = false
        present(vc, animated: true)
    }
}
