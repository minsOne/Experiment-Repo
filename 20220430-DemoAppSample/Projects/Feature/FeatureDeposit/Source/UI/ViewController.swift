import UIKit
import PinLayout
import FlexLayout


public final class ViewController: UIViewController {
    private let mainView = MainView()

    public override func loadView() {
        view = mainView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        mainView.update(title: "입출금통장 개설완료",
                         message: "입출금 통장이 개설되었습니다.\n아래의 내용을 확인해주세요.",
                         계좌종류: "-",
                         일일_이체한도: "1일 최대 200만원",
                         일회_이체한도: "1회 최대 200만원")


        mainView.rootFlexContainer.flex.layout()
        mainView.footerFlexButtonContainer.flex.layout()
    }
}
