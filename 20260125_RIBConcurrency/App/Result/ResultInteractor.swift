import RIBs
import RxSwift

protocol ResultRouting: ViewableRouting {}

nonisolated protocol ResultPresentable: Presentable {
    var listener: ResultPresentableListener? { get set }
}

final nonisolated class ResultInteractor: PresentableInteractor<ResultPresentable>, ResultInteractable, ResultPresentableListener {
    weak var router: ResultRouting?
    var didClose: (() -> Void)?

    override init(presenter: ResultPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didTapClose() {
        didClose?()
    }
}
