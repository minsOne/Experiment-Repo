//
//  AccountBuilder.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/29.
//

import RIBs

final class AccountComponent: Component<EmptyDependency> {}

// MARK: - Builder

protocol AccountBuildable: Buildable {
    func build(withListener listener: AccountListener) -> AccountRouting
}

final class AccountBuilder: Builder<EmptyDependency>, AccountBuildable {
    init() {
        super.init(dependency: EmptyComponent())
    }

    func build(withListener listener: AccountListener) -> AccountRouting {
        let component = AccountComponent(dependency: dependency)
        let viewController = AccountViewController()
        let interactor = AccountInteractor(presenter: viewController)
        interactor.listener = listener
        return AccountRouter(interactor: interactor, viewController: viewController)
    }
}
