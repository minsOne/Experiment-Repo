//
//  UI.swift
//  FeatureDemandDepositInterface
//
//  Created by minsOne on 2022/09/26.
//  Copyright © 2022 minsone. All rights reserved.
//

import Foundation
import UIKit
import DIContainer
import RIBs


public protocol RootComponentFactory {
    func makePresenter() -> RootPresentable & RootViewControllable
    func makeBuilder(dependency: RootDependency) -> RootBuildable
}

public struct RootComponentFactoryKey: InjectionKey {
    public var type: RootComponentFactory?
}

public protocol RootRepository {
    func requestService()
}

public protocol RootRouting: ViewableRouting {
    func requestRoute()
}

public protocol RootPresentable: Presentable {
    var listener: RootPresentableListener? { get set }
    func update(state: RootPresentState)
}

public protocol RootListener: AnyObject {
    func requestListener()
}

public protocol RootInteractable: Interactable {
    var router: RootRouting? { get set }
    var listener: RootListener? { get set }
}

public protocol RootViewControllable: ViewControllable {}

public protocol RootDependency: Dependency {}

public protocol RootBuildable: Buildable {
    func build(withListener listener: RootListener) -> RootRouting
}

public protocol RootPresentableListener: AnyObject {
    func request(action: RootAction)
}

public enum RootAction {
    case viewDidLoad
    case touchedConfirm
}

public struct RootPresentState {
    public let title: String
    public let desc: String
}
