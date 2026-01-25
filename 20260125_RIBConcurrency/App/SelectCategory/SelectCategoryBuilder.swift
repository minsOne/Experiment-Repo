import RIBs
import UIKit

protocol SelectCategoryDependency: Dependency {}

final nonisolated class SelectCategoryComponent: Component<SelectCategoryDependency> {}

protocol SelectCategoryBuildable: Buildable {
    // ✅ 클로저를 주입받는 인터페이스
    func build(onSelect: @escaping (TransferCategory) -> Void) -> SelectCategoryRouting
}

final nonisolated class SelectCategoryBuilder: Builder<SelectCategoryDependency>, SelectCategoryBuildable {
    func build(onSelect: @escaping (TransferCategory) -> Void) -> SelectCategoryRouting {
        let component = SelectCategoryComponent(dependency: dependency)
        let viewController = SelectCategoryViewController()
        let interactor = SelectCategoryInteractor(presenter: viewController)
        interactor.didSelectCategory = onSelect

        return SelectCategoryRouter(interactor: interactor, viewController: viewController)
    }
}
