import RIBs

nonisolated protocol SelectCategoryInteractable: Interactable {
    var router: SelectCategoryRouting? { get set }
}

protocol SelectCategoryViewControllable: ViewControllable {}

final class SelectCategoryRouter: ViewableRouter<SelectCategoryInteractable, SelectCategoryViewControllable>, SelectCategoryRouting {
    override nonisolated init(interactor: SelectCategoryInteractable, viewController: SelectCategoryViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
