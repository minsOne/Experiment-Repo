import RIBs
import RxSwift

protocol RootRouting: ViewableRouting {
    func routeToTransfer()
    func detachTransfer()
}

nonisolated protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
    // Declare methods the interactor can invoke the presenter to present data.
}

protocol RootListener: AnyObject {
    // Declare methods the interactor can invoke to communicate with other RIBs.
}

protocol RootInteractable: Interactable, RootListener, TransferListener {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

final nonisolated class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
    weak var router: RootRouting?
    weak var listener: RootListener?

    // Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: RootPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // Pause any business logic.
    }

    func didTapTransfer() {
        router?.routeToTransfer()
    }

    @MainActor
    func didFinishTransfer() {
        router?.detachTransfer()
    }
}
