import RIBs
import RxSwift
import UIKit

protocol ConfirmPresentableListener: AnyObject {
    func didTapConfirm()
    func didTapCancel()
}

final class ConfirmViewController: UIViewController, ConfirmPresentable, ConfirmViewControllable {

    weak var listener: ConfirmPresentableListener?
    private let amount: Int
    
    init(amount: Int) {
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Confirm"
        
        let label = UILabel()
        label.text = "Send \(amount)?"
        label.textAlignment = .center
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, confirmButton, cancelButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapConfirm() {
        listener?.didTapConfirm()
    }
    
    @objc private func didTapCancel() {
        listener?.didTapCancel()
    }
}
