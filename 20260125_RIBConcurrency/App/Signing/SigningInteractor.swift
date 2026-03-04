import RIBs

protocol SigningRouting: ViewableRouting {}

protocol SigningPresentable: Presentable {
    var listener: SigningPresentableListener? { get set }
}

protocol SigningPresentableListener: AnyObject {}

final nonisolated class SigningInteractor: PresentableInteractor<SigningPresentable>,
    SigningInteractable,
    SigningPresentableListener
{
    weak var router: SigningRouting?

    let completion: (String) -> Void

    init(
        presenter: SigningPresentable,
        completion: @escaping (String) -> Void,
    ) {
        self.completion = completion

        super.init(presenter: presenter)
        presenter.listener = self
    }

    func complete(result: String) {
        completion(result)
    }
}
