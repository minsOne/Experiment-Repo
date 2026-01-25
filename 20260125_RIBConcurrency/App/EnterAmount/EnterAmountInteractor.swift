import RIBs
import RxSwift

protocol EnterAmountRouting: ViewableRouting {
}

nonisolated
protocol EnterAmountPresentable: Presentable {
    var listener: EnterAmountPresentableListener? { get set }
}

final class EnterAmountInteractor: PresentableInteractor<EnterAmountPresentable>, EnterAmountInteractable, EnterAmountPresentableListener {

    weak var router: EnterAmountRouting?
    
    private let amountSubject = ReplaySubject<Int>.create(bufferSize: 1)
    var amountResult: Single<Int> {
        amountSubject.take(1).asSingle()
    }

    nonisolated
    override init(presenter: EnterAmountPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didTapNext(amount: String) {
        if let value = Int(amount) {
            amountSubject.onNext(value)
        }
    }
}
