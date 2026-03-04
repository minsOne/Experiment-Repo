@preconcurrency import RIBs
import RxSwift

protocol TransferRouting: ViewableRouting {
    func routeToEnterAmount() async -> Int?
    func routeToSelectCategory(onSelect: @escaping (TransferCategory) -> Void)
    func routeToConfirm(amount: Int) async -> ConfirmAction?
    func routeToResult() async
    func detachResult()
    func routeToSigning(param: String, onSuccess: @escaping (String) -> Void)
    func routeToSigning(param: String) async -> String
}

nonisolated protocol TransferPresentable: Presentable {
    var listener: TransferPresentableListener? { get set }
}

protocol TransferListener: AnyObject {
    func didFinishTransfer()
}

final nonisolated class TransferInteractor: PresentableInteractor<TransferPresentable>, TransferInteractable, TransferPresentableListener {
    weak var router: TransferRouting?
    weak var listener: TransferListener?
    @MainActor
    var childTask: Task<Void, any Error>?

    override init(presenter: TransferPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        Task { @MainActor [weak self] in
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

extension TransferInteractor {
    func finish() {
        listener?.didFinishTransfer()

        router?.routeToSigning(
            param: "Param",
            onSuccess: { [weak self] _ in
                self?.router?.detachResult()
            },
        )
    }
}

enum Signing {
    case 등록, 수정, 해지, 중단
}

extension TransferInteractor {
@MainActor
func didTapConfirm(mode: Signing) {
    guard childTask == nil else { return }

    childTask = Task { @MainActor [weak self] in
        defer { self?.childTask = nil }
        try await self?._didTapConfirm(mode: mode)
    }
}

    
    
    func _didTapConfirm(mode: Signing) async throws {
        let signedParam = await router?.routeToSigning(param: "Param")
        try Task.checkCancellation()
        guard let signedParam else { return }

        switch mode {
        case .등록: requestRegister(param: signedParam)
        case .수정: requestModify(param: signedParam)
        case .해지: requestClose(param: signedParam)
        case .중단: requestPause(param: signedParam)
        }
    }
}

// extension TransferInteractor {
//    func didTapConfirm(mode: Signing) {
//        Task { @MainActor [weak self] in
//            try await self?._didTapConfirm(mode: mode)
//        }
//        router?.routeToSigning(
//            param: "Param",
//            onSuccess: { [weak self, mode] signedParam in
//                switch mode {
//                case .등록: self?.requestRegister(param: signedParam)
//                case .수정: self?.requestModify(param: signedParam)
//                case .해지: self?.requestClose(param: signedParam)
//                case .중단: self?.requestPause(param: signedParam)
//                }
//
//            },
//        )
//    }
// }

extension TransferInteractor {
    func requestRegister(param _: String) {}
    func requestModify(param _: String) {}
    func requestClose(param _: String) {}
    func requestPause(param _: String) {}
}
