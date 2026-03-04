import RIBs

// Note: RootViewControllable is already defined in RootViewController.swift usually, so I shouldn't redefine it if it's in the same module.
// But protocols are usually defined in the file where they are primarily used or in the File that defines the conformance.
// In RIBs templates, ViewControllable is often in the ViewController or Router file.
// I already put it in RootViewController.swift. So I won't redefine it here.

final nonisolated class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
    private let transferBuilder: TransferBuildable
    private var transferRouter: ViewableRouting?
    
    init(interactor: RootInteractable,
         viewController: RootViewControllable,
         transferBuilder: TransferBuildable)
    {
        self.transferBuilder = transferBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension RootRouter {
    @MainActor
    func routeToTransfer() {
        let router = self.transferBuilder.build(withListener: interactor)
        self.transferRouter = router
        attachChild(router)
        viewController.present(viewController: router.viewControllable)
    }
}

extension RootRouter {
    @MainActor
    func detachTransfer() {
        guard let router = transferRouter else { return }
        viewController.dismiss(viewController: router.viewControllable)
        detachChild(router)
        self.transferRouter = nil
    }
}
