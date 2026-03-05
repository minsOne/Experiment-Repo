import Foundation
import UIKit

public enum ActualDisappearReason: String, Codable {
    /// 인터랙티브 전환(예: 스와이프 dismiss/pop)이 진행되다가 취소된 경우.
    ///
    /// - 핵심 포인트
    ///   - 사용자가 제스처를 시작했다가 떼는 순간 되돌리면 `viewDidDisappear`가 일시적으로 호출되거나
    ///     호출 타이밍이 불명확해질 수 있다.
    ///   - 이 경우 해당 VC는 화면에서 완전히 제거되지 않았으므로 제거됨으로 분류하면 안 된다.
    ///   - 이 플래그는 `transitionCoordinator`의 전이 상태를 통해 판단한다.
    case interactiveTransitionCancelled = "interactive transition canceled"
    /// `UIViewController`가 현재 모달 체인에서 dismiss 진행 상태일 때.
    ///
    /// - 시그널
    ///   - `isBeingDismissed == true`
    /// - 의미
    ///   - 일반적으로 이 VC가 "자신이 직접 해제 대상"인 케이스.
    case beingDismissed = "isBeingDismissed == true"
    /// 네비게이션 스택에서 pop/스택 제거로 상위 컨테이너 관계가 바뀐 경우.
    ///
    /// - 시그널
    ///   - `isMovingFromParent == true`
    /// - 의미
    ///   - 이 VC가 현재 컨테이너에서 제거(혹은 이동) 중임을 뜻하며,
    ///     페이지 자체가 아닌 컨테이너(popToRoot/pop) 경로와 잘 맞는다.
    case movingFromParent = "isMovingFromParent == true"
    /// 뷰가 윈도우에서 분리되었고, 현재 활성 컨테이너(네비게이션/부모)에 의해 소유되지 않는 상태.
    ///
    /// - 시그널
    ///   - `view.window == nil`
    ///   - `isOwnedByActiveContainer(...) == false`
    /// - 의미
    ///   - `viewDidDisappear`에서 자주 등장하는 “화면이 시각적으로 사라졌지만
    ///     isBeingDismissed/isMovingFromParent 둘 다 명시되지 않는 경계 케이스”에서 유효한 마지막 판별 장치.
    case detachedFromWindowAndNoActiveContainer = "view.window == nil && not owned by active container"
    /// VC가 현재 아직 소속 컨테이너(현재 활성 윈도우 내의 nav/parent)에 존재.
    ///
    /// - 사용 예
    ///   - 오버레이로 다른 VC가 올라온 뒤 아래 VC가 잠시 안보여도,
    ///     `presenting`/상위 컨테이너 소유 관계가 살아있으면 “제거됨 아님”으로 처리.
    case ownedByActiveContainer = "still has active container"
}

public struct ActualDisappearCheck: Codable, Equatable {
    /// 실제 화면 소멸(true) 여부.
    /// `false`는 "아직 상위 컨테이너에 의해 유지되거나 이동/취소 중"임을 의미.
    public let isActualDisappear: Bool
    /// 어떤 규칙으로 판별했는지.
    public let reason: ActualDisappearReason
}

// MARK: - 판단 엔트리
//
// public API:
// - viewDidDisappear에서 호출하면 isActualDisappear 값(삭제/미삭제)과 reason을 함께 반환한다.
// - 순서는 실사용에서 발생하는 오탐/누락을 줄이기 위해 보수적으로 구성했다.
public enum ActualDisappearEvaluator {
    /// VC의 실제 제거 판별을 수행한다.
    ///
    /// 평가 우선순위:
    /// 1) 인터랙티브 취소 여부(최우선)
    ///    - 취소가 먼저 오면 이후 플래그는 신뢰도가 낮으므로 즉시 미삭제 처리.
    /// 2) 모달 dismiss 직접 플래그 (`isBeingDismissed`)
    ///    - 대부분 코드 dismiss/pop의 명시적 종료 신호.
    /// 3) 내비게이션 pop 플래그 (`isMovingFromParent`)
    ///    - stack pop/삭제 직전의 신뢰 신호.
    /// 4) 최종 안전장치 (`window == nil` + 비활성 소유)
    ///    - isBeingDismissed/이동 플래그가 없더라도, 윈도우에서 떨어지고
    ///      활성 컨테이너 소유가 끝난 경우를 제거로 봄.
    /// 5) 그 외
    ///    - overlay 등으로 잠깐 사라진 상태로, 컨테이너가 여전히 유지되는 경우.
    public static func evaluate(_ viewController: UIViewController) -> ActualDisappearCheck {
        // NOTE:
        // - `transitionCoordinator`는 현재 전이 중인 상호작용 전이의 상태를 제공합니다.
        // - 스와이프 시작 후 취소된 케이스는 실제로 제거되지 않았는데도 시스템 이벤트가 애매하게 들어오는 경우가 있어
        //   "취소"를 가장 먼저 필터링해야 오탐을 줄일 수 있다.
        let isInteractiveTransitionCancelled =
            (viewController.transitionCoordinator?.isInteractive == true)
                && (viewController.transitionCoordinator?.isCancelled == true)

        if isInteractiveTransitionCancelled {
            return .init(
                isActualDisappear: false,
                reason: .interactiveTransitionCancelled,
            )
        }

        if viewController.isBeingDismissed {
            return .init(
                isActualDisappear: true,
                reason: .beingDismissed,
            )
        }

        if viewController.isMovingFromParent {
            return .init(
                isActualDisappear: true,
                reason: .movingFromParent,
            )
        }

        // view.window == nil 단독으로는 false-positive가 생길 수 있으므로
        // 같은 타이밍에 상위 컨테이너가 아직 살아있는지 함께 검증한다.
        let isOwnedByActiveContainer = isOwnedByActiveContainer(viewController)
        if viewController.view.window == nil, !isOwnedByActiveContainer {
            return .init(
                isActualDisappear: true,
                reason: .detachedFromWindowAndNoActiveContainer,
            )
        }

        return .init(
            isActualDisappear: false,
            reason: .ownedByActiveContainer,
        )
    }

    /// VC가 현재 활성 컨테이너에 의해 실질적으로 소유되는지 판별한다.
    ///
    /// 반환 true 조건:
    /// - VC가 dismiss/이동 플래그 상태가 아니고,
    /// - 소속 내비게이션/Nested parent가 현재 window에 존재하며,
    /// - 해당 VC를 실제 children / viewControllers 배열에 계속 보유하고 있을 때.
    ///
    /// 의미:
    /// - overlay처럼 단순히 가려진 상태나(예: 상위 VC present),
    ///   또는 컨테이너 교체 경로 이전에 잠깐 보이는 중인 상태에서도
    ///   `view.window == nil`만으로 제거로 오판하지 않기 위한 가드.
    private static func isOwnedByActiveContainer(_ viewController: UIViewController) -> Bool {
        // dismiss/삭제 경로의 VC라면 소유 여부 판단 자체를 건너뜀.
        guard !viewController.isBeingDismissed && !viewController.isMovingFromParent else { return false }

        // 1) UINavigationController가 현재 활성 윈도우에 존재하고,
        //    실제 스택 배열에 포함 중이면 소유중으로 본다.
        if let nav = viewController.navigationController,
           !nav.isBeingDismissed,
           nav.view.window != nil,
           nav.viewControllers.contains(viewController)
        {
            return true
        }

        // 2) 일반적인 부모-자식 관계에서 parent가 활성 윈도우에 있고,
        //    children 배열이 이 VC를 유지하면 소유중으로 본다.
        if let parent = viewController.parent,
           parent.view.window != nil,
           parent !== viewController,
           parent.children.contains(viewController)
        {
            return true
        }

        return false
    }
}
