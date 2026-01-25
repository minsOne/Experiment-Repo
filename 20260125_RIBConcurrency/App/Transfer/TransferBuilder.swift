import RIBs
import UIKit

protocol TransferDependency: Dependency {}

final nonisolated class TransferComponent: Component<TransferDependency>, EnterAmountDependency, SelectCategoryDependency, ConfirmDependency, ResultDependency {}

// MARK: - Builder

nonisolated protocol TransferBuildable: Buildable {
    func build(withListener listener: TransferListener) -> TransferRouting
}

final class TransferBuilder: Builder<TransferDependency>, TransferBuildable {
    override nonisolated init(dependency: any TransferDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TransferListener) -> TransferRouting {
        let component = TransferComponent(dependency: dependency)
        let viewController = TransferViewController() // This is a UINavigationController
        let interactor = TransferInteractor(presenter: viewController)
        interactor.listener = listener

        let enterAmountBuilder = EnterAmountBuilder(dependency: component)
        let selectCategoryBuilder = SelectCategoryBuilder(dependency: component)
        let confirmBuilder = ConfirmBuilder(dependency: component)
        let resultBuilder = ResultBuilder(dependency: component)

        return TransferRouter(
            interactor: interactor,
            viewController: viewController,
            enterAmountBuilder: enterAmountBuilder,
            selectCategoryBuilder: selectCategoryBuilder,
            confirmBuilder: confirmBuilder,
            resultBuilder: resultBuilder
        )
    }
}
