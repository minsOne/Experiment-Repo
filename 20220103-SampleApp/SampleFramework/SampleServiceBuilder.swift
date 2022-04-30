//
//  SampleServiceBuilder.swift
//  SampleFramework
//
//  Created by minsOne on 2022/01/30.
//

import RIBs

protocol SampleServiceDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class SampleServiceComponent: Component<SampleServiceDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol SampleServiceBuildable: Buildable {
    func build(withListener listener: SampleServiceListener) -> SampleServiceRouting
}

final class SampleServiceBuilder: Builder<SampleServiceDependency>, SampleServiceBuildable {

    override init(dependency: SampleServiceDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SampleServiceListener) -> SampleServiceRouting {
        let component = SampleServiceComponent(dependency: dependency)
        let viewController = SampleServiceViewController()
        let interactor = SampleServiceInteractor(presenter: viewController)
        interactor.listener = listener
        return SampleServiceRouter(interactor: interactor, viewController: viewController)
    }
}
