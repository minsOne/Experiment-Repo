import RIBs

nonisolated protocol SigningInteractable: Interactable {
    var router: SigningRouting? { get set }
}

protocol SigningViewControllable: ViewControllable {}

final class SigningRouter: ViewableRouter<SigningInteractable, SigningViewControllable>, SigningRouting {
    override nonisolated init(interactor: SigningInteractable, viewController: SigningViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
