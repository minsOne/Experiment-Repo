import RIBs
import UIKit

protocol TransferPresentableListener: AnyObject {
}

final class TransferViewController: UINavigationController, TransferPresentable, TransferViewControllable {

    weak var listener: TransferPresentableListener?
    
    // We don't need viewDidLoad to add subviews because this IS a NavigationController.
    // The Router will push the first view controller.
}
