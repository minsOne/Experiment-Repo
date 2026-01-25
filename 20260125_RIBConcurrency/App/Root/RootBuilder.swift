import RIBs
import UIKit

protocol RootDependency: Dependency {
    // Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final nonisolated class RootComponent: Component<RootDependency>, TransferDependency {
    // Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final nonisolated class RootBuilder: Builder<RootDependency>, RootBuildable {
    func build() -> LaunchRouting {
        let component = RootComponent(dependency: dependency)
        let viewController = RootViewController()
        let interactor = RootInteractor(presenter: viewController)

        let transferBuilder = TransferBuilder(dependency: component)

        return RootRouter(
            interactor: interactor,
            viewController: viewController,
            transferBuilder: transferBuilder
        )
    }
}
