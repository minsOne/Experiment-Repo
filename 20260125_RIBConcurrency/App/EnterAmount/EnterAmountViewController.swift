import RIBs
import RxSwift
import UIKit

protocol EnterAmountPresentableListener: AnyObject {
    func didTapNext(amount: String)
}

final class EnterAmountViewController: UIViewController, EnterAmountPresentable, EnterAmountViewControllable {

    weak var listener: EnterAmountPresentableListener?
    
    private let textField = UITextField()
    private let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Enter Amount"
        
        textField.placeholder = "Amount"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [textField, button])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func didTapNext() {
        listener?.didTapNext(amount: textField.text ?? "")
    }
}
