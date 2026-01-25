import RIBs
import UIKit

protocol ResultDependency: Dependency {}

final nonisolated class ResultComponent: Component<ResultDependency> {}

// MARK: - Builder

protocol ResultBuildable: Buildable {
    func build(onClose: @escaping () -> Void) -> ResultRouting
}

final nonisolated class ResultBuilder: Builder<ResultDependency>, ResultBuildable {
    func build(onClose: @escaping () -> Void) -> ResultRouting {
        let component = ResultComponent(dependency: dependency)
        let viewController = ResultViewController()
        let interactor = ResultInteractor(presenter: viewController)
        interactor.didClose = onClose
        return ResultRouter(interactor: interactor, viewController: viewController)
    }
}
