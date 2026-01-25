import RIBs
import RxSwift
import UIKit

protocol ResultPresentableListener: AnyObject {
    func didTapClose()
}

final class ResultViewController: UIViewController, ResultPresentable, ResultViewControllable {

    weak var listener: ResultPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Result"
        
        let label = UILabel()
        label.text = "Success!"
        label.textAlignment = .center
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [label, closeButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapClose() {
        listener?.didTapClose()
    }
}
