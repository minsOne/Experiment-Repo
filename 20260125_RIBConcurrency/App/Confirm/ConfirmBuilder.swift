import Combine
import RIBs

protocol ConfirmDependency: Dependency {}

final nonisolated class ConfirmComponent: Component<ConfirmDependency> {}

// MARK: - Builder

protocol ConfirmBuildable: Buildable {
    func build(amount: Int) -> (router: ConfirmRouting, result: RIBResult<ConfirmAction>)
}

final nonisolated class ConfirmBuilder: Builder<ConfirmDependency>, ConfirmBuildable {
    func build(amount: Int) -> (router: ConfirmRouting, result: RIBResult<ConfirmAction>) {
        let component = ConfirmComponent(dependency: dependency)
        let viewController = ConfirmViewController(amount: amount)
        let interactor = ConfirmInteractor(presenter: viewController)
        let router = ConfirmRouter(interactor: interactor, viewController: viewController)
        return (router, interactor.actionResult)
    }
}
