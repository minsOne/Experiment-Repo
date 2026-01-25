import RIBs

nonisolated
protocol ConfirmInteractable: Interactable {
    var router: ConfirmRouting? { get set }
}

protocol ConfirmViewControllable: ViewControllable {}

final class ConfirmRouter: ViewableRouter<ConfirmInteractable, ConfirmViewControllable>, ConfirmRouting {
    override nonisolated init(interactor: ConfirmInteractable, viewController: ConfirmViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
