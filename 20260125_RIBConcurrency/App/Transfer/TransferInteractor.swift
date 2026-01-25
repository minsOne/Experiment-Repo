@preconcurrency import RIBs
import RxSwift

protocol TransferRouting: ViewableRouting {
    func routeToEnterAmount() async -> Int?
    func routeToSelectCategory(onSelect: @escaping (TransferCategory) -> Void)
    func routeToConfirm(amount: Int) async -> ConfirmAction?
    func routeToResult() async
    func detachResult()
}

nonisolated protocol TransferPresentable: Presentable {
    var listener: TransferPresentableListener? { get set }
}

nonisolated protocol TransferListener: AnyObject {
    func didFinishTransfer()
}

final nonisolated class TransferInteractor: PresentableInteractor<TransferPresentable>, TransferInteractable, TransferPresentableListener {
    weak var router: TransferRouting?
    weak var listener: TransferListener?
    var task: Task<Void, Never>?

    override init(presenter: TransferPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        task = Task { @MainActor [weak self] in
            await self?.runTransferFlow()
        }
    }

    // MARK: - Transfer Flow

    @MainActor
    private func runTransferFlow() async {
        // 1. 금액 입력 대기
        guard let amount = await router?.routeToEnterAmount() else {
            listener?.didFinishTransfer()
            return
        }

        // 2. 카테고리 선택 대기 (Interactor에서 Closure를 Async로 래핑하는 방식)
        let category: TransferCategory? = await withCheckedContinuation { continuation in
            router?.routeToSelectCategory(onSelect: { category in
                continuation.resume(returning: category)
            })
        }

        guard let category else {
            listener?.didFinishTransfer()
            return
        }

        print("Selected category: \(category)")

        // 3. 확인 대기
        guard let action = await router?.routeToConfirm(amount: amount) else {
            listener?.didFinishTransfer()
            return
        }

        // 3. 액션에 따라 분기
        switch action {
        case .confirmed:
            // 비동기 작업 가능
            // await performTransfer(amount: amount)
            await router?.routeToResult()
            listener?.didFinishTransfer()

        case .cancelled:
            listener?.didFinishTransfer()
        }
    }
}
