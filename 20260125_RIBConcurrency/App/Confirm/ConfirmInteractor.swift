import Combine
import RIBs

protocol ConfirmRouting: ViewableRouting {}

nonisolated
protocol ConfirmPresentable: Presentable {
    var listener: ConfirmPresentableListener? { get set }
}

enum ConfirmAction {
    case confirmed
    case cancelled
}

final class ConfirmInteractor: PresentableInteractor<ConfirmPresentable>, ConfirmInteractable, ConfirmPresentableListener {
    weak var router: ConfirmRouting?

    private let actionSubject = PassthroughSubject<ConfirmAction, Never>()
    var actionResult: RIBResult<ConfirmAction> { .init(actionSubject) }

    override nonisolated init(presenter: ConfirmPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didTapConfirm() {
        actionSubject.send(.confirmed)
    }

    func didTapCancel() {
        actionSubject.send(.cancelled)
    }
}
