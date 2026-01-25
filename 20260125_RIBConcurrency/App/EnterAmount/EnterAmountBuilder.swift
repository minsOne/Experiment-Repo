import RIBs
import RxSwift
import UIKit

protocol EnterAmountDependency: Dependency {}

final nonisolated class EnterAmountComponent: Component<EnterAmountDependency> {}

// MARK: - Builder

protocol EnterAmountBuildable: Buildable {
    func build() -> (router: EnterAmountRouting, result: Single<Int>)
}

final nonisolated class EnterAmountBuilder: Builder<EnterAmountDependency>, EnterAmountBuildable {
    func build() -> (router: EnterAmountRouting, result: Single<Int>) {
        let component = EnterAmountComponent(dependency: dependency)
        let viewController = EnterAmountViewController()
        let interactor = EnterAmountInteractor(presenter: viewController)
        let router = EnterAmountRouter(interactor: interactor, viewController: viewController)
        return (router, interactor.amountResult)
    }
}
