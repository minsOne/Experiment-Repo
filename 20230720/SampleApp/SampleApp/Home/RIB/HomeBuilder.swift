//
//  HomeBuilder.swift
//  SampleApp
//
//  Created by minsOne on 2023/07/18.
//

import RIBs

// MARK: - Builder

protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<EmptyDependency>, HomeBuildable {
    init() {
        super.init(dependency: EmptyComponent())
    }

    func build(withListener listener: HomeListener) -> HomeRouting {
        let viewController = HomeViewController()
        let interactor = HomeInteractor(presenter: viewController)
        interactor.listener = listener
        return HomeRouter(interactor: interactor, viewController: viewController)
    }
}
