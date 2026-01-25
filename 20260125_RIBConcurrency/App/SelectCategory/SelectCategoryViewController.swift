import RIBs
import UIKit

protocol SelectCategoryPresentableListener: AnyObject {
    func didSelect(category: TransferCategory)
}

final class SelectCategoryViewController: UIViewController, SelectCategoryPresentable, SelectCategoryViewControllable {
    weak var listener: SelectCategoryPresentableListener?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "카테고리 선택"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        TransferCategory.allCases.forEach { category in
            let button = UIButton(type: .system)
            button.setTitle(category.rawValue, for: .normal)
            button.addAction(UIAction { [weak self] _ in
                self?.listener?.didSelect(category: category)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
}
