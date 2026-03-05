# ViewController Dismiss 감지 검증 데모 + UITest

UIKit 기반 iOS 15.0+ 샘플 프로젝트입니다. SwiftUI/외부 라이브러리 없이 `viewDidDisappear + view.window` 조합 동작을 시나리오로 검증합니다.

## 프로젝트 구성
- `AppDelegate.swift`
- `RootViewController.swift`
- `BaseScenarioViewController.swift`
- `ScenarioViewControllers.swift`
- `LifecycleEventLogger.swift`
- `DismissProbeUITests/DismissProbeUITests.swift`
- `Packages/DismissProbeValidation` (로컬 Swift Package, 판정 규칙 분리)
- `DismissProbe.xcodeproj` (xcodegen으로 생성)
- `project.yml`

## 생성된 테스트 시나리오 (8개)
- 시나리오 1: 코드로 modal dismiss
- 시나리오 2: 스와이프 dismiss
- 시나리오 3: 스와이프 취소
- 시나리오 4: Navigation pop
- 시나리오 5: NavigationController 전체 dismiss
- 시나리오 6: popToRoot
- 시나리오 7: 위에 overlay present 오탐 방지
- 시나리오 8: fullScreen pull dismiss

각 시나리오의 ChildVC는 배경색을 구분하고 클래스명 라벨이 표시됩니다.

`BaseScenarioViewController`에서 `viewDidDisappear` 진입 시 아래 로그를 출력합니다.

```swift
print("[\(vcName)] viewDidDisappear")
print("  isBeingDismissed: \(isBeingDismissed)")
print("  isMovingFromParent: \(isMovingFromParent)")
print("  view.window: \(view.window == nil ? "nil" : "exists")")
print("  presentingVC: \(presentingViewController == nil ? "nil" : "exists")")
print("  navigationController: \(navigationController == nil ? "nil" : "exists")")
```

실제 제거 판별은 Swift Package의 `ActualDisappearEvaluator`가 처리합니다.

```swift
import DismissProbeValidation

let check = ActualDisappearEvaluator.evaluate(self)
// check.isActualDisappear -> 실제로 제거되었는지
// check.reason -> 판단 사유 (isBeingDismissed/movingFromParent/detachedFromWindowAndNoActiveContainer 등)
```

판단 순서:
1. 인터랙티브 전환이 취소된 경우 `isActualDisappear = false`
2. `isBeingDismissed == true`면 `true`
3. `isMovingFromParent == true`면 `true`
4. `view.window == nil`이며 `isOwnedByActiveContainer == false`면 `true`
5. 그 외는 `false`

`isOwnedByActiveContainer`는 외부 주입 없이 `UIViewController`의 현재 소속 정보를 기준으로 내부 판단합니다.

추가로 동일 로그를 `DISMISS_UI_TEST_LOG_PATH` 경로에 JSONL 형태로 저장해서 UITest에서 검증합니다.

## 실행 방법
1. Xcode와 XcodeGen이 설치되어 있어야 합니다.
2. 아래 명령으로 프로젝트 생성 (이미 생성되어 있다면 생략 가능)
   - `cd /Users/minsone/Developer/Experiment-Repo/20260305`
   - `xcodegen generate`
3. Xcode에서 `DismissProbe.xcodeproj`를 열고 시뮬레이터에서 실행.

## UITest 실행 방법
- Xcode에서 `DismissProbe` Scheme을 선택 후 Test 실행
- 또는 커맨드라인
  - `cd /Users/minsone/Developer/Experiment-Repo/20260305`
  - `Scripts/run_ui_tests.sh`

원하면 즉시 대상 기기를 지정해 실행:
  - `Scripts/run_ui_tests.sh "platform=iOS Simulator,name=iPhone 15 Pro"`
  - `Scripts/run_matrix.sh` (샘플: iPhone/iPad 시뮬레이터 연속 실행)

### 분석/공유 자료
- 테스트 로그 기반으로 `view.window == nil` 사용 가이드와 시나리오별 판정 근거를 정리했습니다.
  - [VIEW_WINDOW_NIL_DISMISS_VALIDATION_REPORT.md](/Users/minsone/Developer/Experiment-Repo/20260305/VIEW_WINDOW_NIL_DISMISS_VALIDATION_REPORT.md)
- 결과 템플릿에 시뮬레이터 런( iPhone 15 / iOS 17.2 ) 값을 반영해 두었습니다.
  - [RESULT_MATRIX_TEMPLATE.md](/Users/minsone/Developer/Experiment-Repo/20260305/RESULT_MATRIX_TEMPLATE.md)

### 테스트 동작 포인트
- 각 테스트가 시나리오 버튼을 탭하고, 해당 액션(버튼/스와이프/팝 등)을 수행한 뒤
- 로그 파일에 남은 `viewDidDisappear` 이벤트의 `isBeingDismissed`, `isMovingFromParent`, `viewWindowIsNil` 값을 비교해 검증
- 시나리오 3/7은 dismiss되지 않아야 하는 경우를 먼저 확인하고, 필요한 경우 정리 동작을 수행
- 이벤트 집계(디버그용):
  - `Scripts/summarize_dismiss_probe_events.sh /path/to/dismiss-probe-events.jsonl`

실제 기기별 기록 템플릿:
- [RESULT_MATRIX_TEMPLATE.md](RESULT_MATRIX_TEMPLATE.md)

## 기대 결과 매트릭스(실행 후 채움)

| 시나리오 | isBeingDismissed | isMovingFromParent | view.window == nil | 감지 성공? |
|---------|:-:|:-:|:-:|:-:|
| 1. Modal dismiss (코드) | `true` | `false` | `true` | `true` |
| 2. 스와이프 dismiss | `true` | `false` | `true` | `true` |
| 3. 스와이프 취소 | (호출 없음) | - | - | `true` |
| 4. Nav pop | `false` | `true` | `true` | `true` |
| 5. NavController dismiss - A | `false` | `false` | `true` | `true` |
| 5. NavController dismiss - B | `false` | `false` | `true` | `true` |
| 5. NavController dismiss - C | `false` | `false` | `true` | `true` |
| 6. popToRoot - A (중간) | `false` | `false` | `true` | `true` |
| 6. popToRoot - B (중간) | `false` | `false` | `true` | `true` |
| 6. popToRoot - C (최상단) | `false` | `true` | `true` | `true` |
| 7. 위에 VC present (오탐) | (호출 없음) | - | `false` | `true` |
| 8. fullScreen pull dismiss | `true` 또는 `false` | `false` 또는 `true`(detail) | `true`(close) / `false`(detail) | `true` |

## 실기기/시뮬레이터 기준 기대치

- iOS 15.0+ 기준으로 `시나리오 1~8`의 플래그 조합은 실기기와 시뮬레이터에서 동일하게 관측되는 것을 전제로 작성했습니다.
- 차이가 생기면 `iOS 버전/디바이스 계열/인터랙션 타이밍`을 함께 기록해 다시 보정합니다.
- 핵심 판정 기준:
  - 1, 2: dismiss 성공 시 `view.window == nil` + (모달 dismiss는 `isBeingDismissed == true`)
  - 3: 취소 시 `viewDidDisappear` **미호출**
  - 4: pop 시 `isMovingFromParent == true`
  - 5: nav controller 단위 dismiss에서 하위 VC 3개 모두 `isBeingDismissed == false`, `isMovingFromParent == false`, `view.window == nil`
  - 6: popToRoot에서 중간 VC들은 `isMovingFromParent == false`, 최상단 C에서 `isMovingFromParent == true`, 모두 `view.window == nil`
  - 7: overlay가 있을 때는 `view.window != nil`이 유지되어 dismiss 오탐이 나면 안 됨
  - 8: fullScreen 시나리오에서 detail pop은 `isMovingFromParent == true`, 최상단 close는 `isBeingDismissed == true` 또는 `detachedFromWindowAndNoActiveContainer`

## 테스트 통과 기준 집계 예시

| 항목 | 통과 기준 |
|---|---|
| 시나리오별 이벤트 존재/부재 | 위 매트릭스 조건 충족 |
| 콘솔/로그 일치 | `viewDidDisappear` 로그 라인이 매트릭스 플래그와 일치 |
| 오탐 탐지 방지 | 시나리오 7에서 overlay 구간 중 `Scenario7ChildViewController`의 `viewDidDisappear` 미호출 |

## `ActualDisappearEvaluator` 규칙 해설 (상세)

`ActualDisappearEvaluator`는 `viewDidDisappear` 시점에서 “실제 제거 여부”를 판별합니다.

- `interactiveTransitionCancelled`
  - `transitionCoordinator`가 `isInteractive == true`이면서 `isCancelled == true`인 경우.
  - **가장 먼저** 처리합니다.
  - 이유: 스와이프 제스처가 취소된 뒤에도 이벤트 타이밍이 섞여 들어올 수 있어, 이 경우를 최우선으로 제외해야 오탐을 줄일 수 있습니다.

- `beingDismissed`
  - `isBeingDismissed == true`.
  - 일반 모달 dismiss 경로의 명시적 신호입니다.

- `movingFromParent`
  - `isMovingFromParent == true`.
  - `push -> pop` 계열에서 VC가 부모 컨테이너에서 제거되거나 이동하는 시그널입니다.

- `detachedFromWindowAndNoActiveContainer`
  - `view.window == nil` 이고 `isOwnedByActiveContainer(...) == false`인 경우.
  - `isBeingDismissed`/`isMovingFromParent` 플래그가 아직 반영되지 않은 경계 케이스에서 최종 판정으로 사용합니다.

- `ownedByActiveContainer`
  - 위 모든 종료 조건을 못 충족하고, 현재 활성 컨테이너에 여전히 소유되고 있다고 판단될 때 사용합니다.
  - 대표적으로 `overCurrentContext`/`fullScreen` 상황에서 아래 VC가 잠깐 가려져도 소유권이 유지되는 경우입니다.

### `isOwnedByActiveContainer` 판단 기준

- `isBeingDismissed`, `isMovingFromParent`가 이미 true면 즉시 false.
- 네비게이션 컨테이너:
  - `navigationController != nil`
  - `navigationController.view.window != nil`
  - `viewControllers` 배열이 대상 VC를 포함
- 또는 parent-child 관계:
  - `parent != nil`
  - `parent.view.window != nil`
  - `parent.children` 배열이 대상 VC를 포함
- 어느 쪽도 아니면 활성 컨테이너 소유로 볼 수 없어 `false`.

### 판단 우선순위를 정한 이유 (한줄 요약)

- 취소(interactive cancel) → 직접 신호(isBeingDismissed / movingFromParent) → 윈도우 분리 + 소유권 부재 → 아직 유지(owned)  
- 핵심 목적은 “실제로 삭제된 상태”와 “단순히 가려지거나 이동 중인 상태”를 정확히 분리하는 것입니다.
