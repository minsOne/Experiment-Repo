import RIBs

nonisolated protocol EnterAmountInteractable: Interactable {
    var router: EnterAmountRouting? { get set }
}

protocol EnterAmountViewControllable: ViewControllable {}

final class EnterAmountRouter: ViewableRouter<EnterAmountInteractable, EnterAmountViewControllable>, EnterAmountRouting {
    override nonisolated init(interactor: EnterAmountInteractable, viewController: EnterAmountViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
