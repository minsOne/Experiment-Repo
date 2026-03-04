//
//  SigningBuilder.swift
//  App
//
//  Created by 안정민 on 2/22/26.
//

import RIBs

protocol SigningBuildable: Buildable {
    func build(onSuccess: @escaping (String) -> Void) -> ViewableRouting
}

final nonisolated class SigningBuilder: SigningBuildable {
    func build(onSuccess: @escaping (String) -> Void) -> ViewableRouting {
        let viewController = SigningViewController()
        let interactor = SigningInteractor(
            presenter: viewController,
            completion: onSuccess,
        )
        return SigningRouter(interactor: interactor,
                             viewController: viewController)
    }
}
