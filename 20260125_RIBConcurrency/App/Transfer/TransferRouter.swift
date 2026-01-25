import Combine
import RIBs
import RxSwift
import UIKit

nonisolated protocol TransferInteractable: Interactable {
    var router: TransferRouting? { get set }
    var listener: TransferListener? { get set }
}

protocol TransferViewControllable: ViewControllable {
    func push(viewController: ViewControllable)
    func pop()
}

// Extend UINavigationController to conform to TransferViewControllable
extension TransferViewController {
    func push(viewController: ViewControllable) {
        pushViewController(
            viewController.uiviewController,
            animated: true,
        )
    }

    func pop() {
        popViewController(animated: true)
    }
}

final nonisolated class TransferRouter: ViewableRouter<TransferInteractable, TransferViewControllable>, TransferRouting {
    // Child builders
    private let enterAmountBuilder: EnterAmountBuildable
    private let selectCategoryBuilder: SelectCategoryBuildable
    private let confirmBuilder: ConfirmBuildable
    private let resultBuilder: ResultBuildable

    // Current child
    private var currentChild: ViewableRouting?

    init(interactor: TransferInteractable,
         viewController: TransferViewControllable,
         enterAmountBuilder: EnterAmountBuildable,
         selectCategoryBuilder: SelectCategoryBuildable,
         confirmBuilder: ConfirmBuildable,
         resultBuilder: ResultBuildable)
    {
        self.enterAmountBuilder = enterAmountBuilder
        self.selectCategoryBuilder = selectCategoryBuilder
        self.confirmBuilder = confirmBuilder
        self.resultBuilder = resultBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToEnterAmount() async -> Int? {
        let (router, result) = enterAmountBuilder.build()
        attachChild(router)
        viewController.push(viewController: router.viewControllable)
        currentChild = router

        let amount = try? await result.value

        detachChild(router)
        currentChild = nil
        return amount
    }

    @MainActor
    func routeToSelectCategory(onSelect: @escaping (TransferCategory) -> Void) {
        var childRouter: SelectCategoryRouting?

        let router = selectCategoryBuilder.build(onSelect: { [weak self] category in
            // Detach 로직
            if let router = childRouter {
                self?.detachChild(router)
            }
            if self?.currentChild === childRouter {
                self?.currentChild = nil
            }
            // 결과 반환
            onSelect(category)
        })

        childRouter = router
        attachChild(router)
        viewController.push(viewController: router.viewControllable)
        currentChild = router
    }

    func routeToConfirm(amount: Int) async -> ConfirmAction? {
        let (router, result) = confirmBuilder.build(amount: amount)
        attachChild(router)
        viewController.push(viewController: router.viewControllable)
        
        // ✅ Combine + Never 이므로 try?가 필요 없음
        let action = await result.asyncValue

        detachChild(router)
        return action
    }

    func routeToResult() async {
        await withCheckedContinuation { continuation in
            _routeToResult {
                continuation.resume()
            }
        }
    }

    private func _routeToResult(onClose: @escaping () -> Void) {
        var childRouter: ResultRouting?
        let router = resultBuilder.build(onClose: { [weak self] in
            if let router = childRouter {
                self?.detachChild(router)
            }
            onClose()
        })
        childRouter = router
        attachChild(router)
        viewController.push(viewController: router.viewControllable)
    }

    func detachResult() {}
}
