import RIBs

public enum TransferCategory: String, CaseIterable {
    case food = "식비"
    case transport = "교통비"
    case shopping = "쇼핑"
    case others = "기타"
}

protocol SelectCategoryRouting: ViewableRouting {}

protocol SelectCategoryPresentable: Presentable {
    var listener: SelectCategoryPresentableListener? { get set }
}

final class SelectCategoryInteractor: PresentableInteractor<SelectCategoryPresentable>, SelectCategoryInteractable, SelectCategoryPresentableListener {
    weak var router: SelectCategoryRouting?
    
    // ✅ 순수 클로저 방식
    var didSelectCategory: ((TransferCategory) -> Void)?

    override nonisolated init(presenter: SelectCategoryPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didSelect(category: TransferCategory) {
        didSelectCategory?(category)
    }
}
