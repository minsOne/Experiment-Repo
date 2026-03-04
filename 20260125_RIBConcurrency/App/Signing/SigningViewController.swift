import RIBs
import UIKit

final class SigningViewController: UIViewController, SigningPresentable, SigningViewControllable {
    weak var listener: SigningPresentableListener?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "전자서명 선택"

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        for category in TransferCategory.allCases {
            let button = UIButton(type: .system)
            button.setTitle(category.rawValue, for: .normal)
            button.addAction(UIAction { [weak self] _ in
//                self?.listener?.didSelect(category: category)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
}
