# View.window == nil 기반 Dismiss 감지 근거 자료

## 목적
- `viewDidDisappear` 발생 시 `view.window == nil`를 dismiss 탐지 조건으로 사용할 수 있는지
- UIKit 7개 시나리오 로그 기반으로 검증 가능성/한계 정리

## 실험 근거
- 앱 내 공통 로거 (`BaseScenarioViewController + DismissProbeLifecycleLogger`)에서 `viewDidDisappear` 직후 아래 값을 기록
  - `isBeingDismissed`
  - `isMovingFromParent`
  - `viewWindowIsNil`
- 실제 시뮬레이터 실행 로그 경로
  - `/tmp/dismiss-probe-diag/0_Test_iPhone 17_Diagnostics/.../StandardOutputAndStandardError-com.dismissprobe.demo.txt`
- 파싱 대상 이벤트 로그 요약 (발췌)
  - `Scenario1`: `isBeingDismissed=true`, `isMovingFromParent=false`, `view.window=nil`
  - `Scenario4`: `isBeingDismissed=false`, `isMovingFromParent=true`, `view.window=nil`
  - `Scenario5C`: `isBeingDismissed=false`, `isMovingFromParent=false`, `view.window=nil`
  - `Scenario6C`: `isBeingDismissed=false`, `isMovingFromParent=true`, `view.window=nil`
  - `Scenario7Overlay`: `isBeingDismissed=true`, `isMovingFromParent=false`, `view.window=nil`
  - `Scenario7Child`: `isBeingDismissed=false`, `isMovingFromParent=true`, `view.window=nil` (overlay dismiss 후 pop 시점)

> 유의: `Scenario5A/B`, `Scenario6A/B`, `Scenario2`, `Scenario3`는 `viewDidDisappear` 로그가 런에서 수집되지 않아 판단 근거가 미완성입니다.

## 시나리오별 판단 요약

| 시나리오 | 핵심 기대 | 관측값/근거 | 판정 |
|---|---|---|---|
| 1. Modal Dismiss(코드) | isBeingDismissed=true + view.window=nil | 관측 일치 | ✅ 사용 근거 충족 |
| 2. Swipe Dismiss | isBeingDismissed=true + view.window=nil | 이벤트 미수집 | ⚠️ 미확인 |
| 3. Swipe Cancel | `viewDidDisappear` 미호출 | 이벤트 미수집 (테스트 설계/타이밍 불안정) | ⚠️ 미확인 |
| 4. Nav Pop | isMovingFromParent=true + view.window=nil | 관측 일치 | ✅ 사용 근거 충족 |
| 5. NavController Dismiss | A/B/C 각각 view.window=nil | C만 관측. A/B 미수집 | ⚠️ 부분 미확인 |
| 6. popToRoot | C: isMovingFromParent=true + nil, A/B 없음 | C 관측 일치, A/B 미수집 | ⚠️ 부분 미확인 |
| 7. Overlay Present 오탐 방지 | Child는 overlay 중에도 `view.window != nil`, 오탐 없음 | Child 이벤트 미수집 구간 존재 + 최종 pop에서만 `viewDidDisappear` 발생 | ✅ 보조 근거(실행 테스트 통과 기준으로 확인) |

## 결론: `view.window == nil`를 단독으로 사용해도 되는가?

- **단독 사용은 권장되지 않습니다.**
  - 이유: `view.window == nil`은 라이프사이클 상태의 보조 신호일 뿐, `isBeingDismissed`/`isMovingFromParent`와 같이 “어떤 경로로 사라지는지”를 설명하지 못합니다.
- **권장:** 결합 규칙으로 사용
  - `isBeingDismissed || isMovingFromParent`가 `true`이면 dismiss/pop 계열로 판단
  - 양쪽이 `false`이더라도 `view.window == nil`가 나오면 상위 컨테이너 제거/계층 분리 가능성(예: 포함된 네비게이션 계층 해제)으로 추가 확인

권장 구현 예시:

```swift
private enum DismissSignal {
    case modal
    case navigation
    case detachedOnly
    case other
}

func dismissSignalForVC(_ vc: UIViewController) -> DismissSignal {
    if vc.isBeingDismissed { return .modal }
    if vc.isMovingFromParent { return .navigation }
    if vc.view.window == nil { return .detachedOnly }
    return .other
}
```

- 특히 `Scenario7`처럼 상위 VC가 overlay 되더라도 하위 VC는 `view.window`가 유지되어야 하므로, 오탐 방지에는 `view.window == nil`이 유효한 보조 체크 포인트입니다.

## 즉시 반영 가능한 점검 포인트
- `viewDidDisappear` 미수집 케이스(시나리오 2,5A/B,6A/B,3)는 현재 UITest 타이밍/동작 방식 재설계가 필요
  - 예: `viewWillAppear`/`viewWillDisappear`도 함께 수집, `isMovingFromParent`/`presentingViewController` 변경 시점 분리 로깅, interaction-driven dismiss는 안정적인 wait 전략 사용
- 실기기(iOS 17/18+)와 최소 1대의 iPad iOS 버전으로 동일 매트릭스 재수집 권장
- 동일 앱 로그(`DISMISS_UI_TEST_LOG_PATH`)로 실기기 결과와 시뮬레이터 결과를 비교하면 판단 규칙의 이식성을 정량화 가능
