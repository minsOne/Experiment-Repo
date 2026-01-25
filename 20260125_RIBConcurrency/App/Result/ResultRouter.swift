import RIBs

nonisolated
protocol ResultInteractable: Interactable {
    var router: ResultRouting? { get set }
}

protocol ResultViewControllable: ViewControllable {}

final class ResultRouter: ViewableRouter<ResultInteractable, ResultViewControllable>, ResultRouting {
    override nonisolated init(interactor: ResultInteractable, viewController: ResultViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
