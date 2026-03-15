# RIBs Implementation Guide for Case-Centric Recovery Architecture

- Status: Working Guide
- Canonical Spec: [`case-centric-recovery-architecture.md`](./case-centric-recovery-architecture.md)
- Design History: [`case-centric-recovery-architecture-history.md`](./case-centric-recovery-architecture-history.md)
- Audience: iOS / Platform / Feature Engineers
- Purpose: Case-Centric Recovery Architecture 안에서 RIB를 어떻게 나누고, 붙이고, 떼고, 통신시키고, 검증할지 구현 기준을 고정한다.

---

## 1. 이 문서의 역할

메인 사양서는 정책, 계약, 운영 기준을 고정한다.

이 문서는 그 정책을 RIB 구조로 구현할 때 필요한 아래 질문에 답한다.

- 어떤 RIB가 무엇을 소유하는가
- attach / detach / back / swipe / modal dismiss는 누가 확정하는가
- child -> parent 통신은 어떤 수단을 써야 하는가
- feature entry를 누가 결정하는가
- feature 팀이 신규 case를 붙일 때 무엇을 구현해야 하는가

---

## 2. 핵심 원칙

1. RIB tree는 business truth 저장소가 아니다.
2. `CaseSnapshot`이 truth이고, RIB는 그 결정을 실행한다.
3. `FeatureChildRIB`는 자기 case의 업무 UI와 로컬 action만 담당한다.
4. session / security / reset / terminal 결정은 platform RIB가 담당한다.
5. owner가 attach하고 owner가 detach한다.
6. gesture와 dismiss는 intent이며, detach truth는 owner completion이다.

---

## 3. 표준 RIB 트리

```text
AppRootRIB
└─ SessionRootRIB
   ├─ MainRootRIB
   └─ RecoveryHostRIB
      ├─ CaseShellRIB
      │  └─ FeatureChildRIB
      └─ BlockingStateRIB
```

| RIB | 책임 | 금지 |
|---|---|---|
| `AppRootRIB` | 앱 전체 composition root 연결 | case 판단 |
| `SessionRootRIB` | 로그인 세션 경계, session reset 재구성 | feature route 결정 |
| `MainRootRIB` | 일반 메인 앱 영역 | recovery decision 소유 |
| `RecoveryHostRIB` | recovery 실행 호스트, attach/detach 직렬화, primary scene write lock | feature business 해석 |
| `CaseShellRIB` | case 복구의 안정 부모, shell-safe 상태 표면, case actor ownership | session/security 최종 판단 |
| `FeatureChildRIB` | 현재 case의 업무 단계 UI와 로컬 action | 다른 feature attach, global reset |
| `BlockingStateRIB` | wrong-user, expired, completedElsewhere, securityBlocked, safeLanding 표면 | 업무 입력 소유 |

---

## 4. Lifecycle / Ownership Invariants

1. 한 시점에 하나의 active `CaseShellRIB`만 primary recovery 흐름을 가진다.
2. 한 `CaseShellRIB` 아래에는 동시에 하나의 `FeatureChildRIB`만 존재한다.
3. `BlockingStateRIB`가 attach된 동안 `FeatureChildRIB`는 입력을 받을 수 없다.
4. `caseReset`이면 기존 child를 먼저 detach한 뒤 새 child를 attach한다.
5. `sessionReset`이면 recovery subtree 전체를 detach한 뒤 `SessionRootRIB`를 재구성한다.
6. `CaseShellRIB.detach()`는 view 제거가 아니라 case actor / task / observer / timer 정리까지 포함한다.

| 이벤트 | SessionRootRIB | RecoveryHostRIB | CaseShellRIB | FeatureChildRIB |
|---|---|---|---|---|
| case 시작 | 유지 | 유지 | attach | attach |
| inPlace recovery | 유지 | 유지 | 유지 | 유지 또는 교체 |
| caseReset | 유지 | 유지 | 유지 또는 re-attach | detach 후 새 child attach |
| sessionReset | 재구성 | detach 후 재구성 | detach | 전부 detach |
| terminal ack 후 종료 | 유지 | 유지 | detach 가능 | detach |

---

## 5. Child -> Parent 통신 규칙

### 5.1 기본 표준

| 신호 종류 | 권장 수단 | 허용 조건 |
|---|---|---|
| topology 변경 가능성이 있는 구조적 신호 | `typed IntentSink` 또는 listener | 기본값 |
| same-case leaf one-shot completion | `Closure` | topology 변화 없음, authoritative 재판단 없음, detach 후 no-op |
| stream / lifecycle / late event / serialization | Swift Concurrency | UI topology 직접 변경 금지 |

### 5.2 금지

- feature -> feature direct import
- child가 sibling을 직접 attach / detach
- raw `AsyncStream`으로 route topology를 직접 변경
- closure로 cross-case transition, securityBlocked, sessionReset을 우회

### 5.3 intent 예시

- same-case 다음 단계: `FeatureRouteIntent`
- 다른 case 요청: `CrossCaseRequestIntent`
- explicit back: `FeatureRouteIntent.back`

레퍼런스 코드는 [`references/ribs-attach-detach-reference.swift`](./references/ribs-attach-detach-reference.swift)를 따른다.

---

## 6. Feature Entry 구현 규칙

정책 기준은 메인 사양서의 `Navigation & Shell Spec > entry policy`를 따른다.

### 6.1 허용되는 entry model

| 모델 | 언제 쓰는가 | 누가 결정하는가 |
|---|---|---|
| `shellFirstAuthoritative` | external return, deep link, cold start, resume, blocked/pending/terminal 가능성 있음 | `FeatureEntryCoordinator` |
| `inlinePushContinuation` | same-case, same-route-family, 즉시 actionable, authoritative fetch 불필요 | `FeatureEntryCoordinator` |
| `auxiliaryLocalEntry` | 주소 검색, 도움말, picker, 문서 미리보기 등 보조 흐름 | 현재 feature owner |

### 6.2 구현 원칙

1. 기존 화면이 직접 entry policy를 결정하지 않는다.
2. `FeatureEntryCoordinator`가 `EntryDecision`만 결정한다.
3. shell-first가 기본값이고, inline push는 제한적 예외다.
4. auxiliary는 본 기능 진입과 분리한다.

---

## 7. Attach / Detach 패턴

### 7.1 ownership 표

| 대상 | attach owner | detach owner | child가 할 수 있는 것 |
|---|---|---|---|
| `FeatureChildRIB` | `CaseShellRIB` 또는 그 Router | 동일 owner | back / close / next intent 전달 |
| feature 내부 sub-RIB | 해당 feature parent RIB | 동일 owner | dismiss 요청 |
| `BlockingStateRIB` | `RecoveryHostRIB` | `RecoveryHostRIB` | 확인 버튼 intent |
| `CaseShellRIB` | `RecoveryHostRIB` | `RecoveryHostRIB` | case 종료 / 전환 intent |
| `SessionRootRIB` 이하 subtree | `AppRootRIB` | `AppRootRIB` | logout / sessionChanged signal |

### 7.2 same-case 다음 단계

1. child가 `route intent`를 올린다.
2. parent owner가 current case / route family를 해석한다.
3. 동일 case / 동일 route family면 push 또는 child replacement를 선택한다.
4. 기존 child는 owner completion 기준으로 cleanup / detach 한다.

### 7.3 same-case auxiliary

- modal / sheet / sub-RIB로 처리한다.
- case truth는 바꾸지 않는다.
- 닫히면 원래 child로 복귀한다.

### 7.4 cross-case 요청

1. feature는 `CrossCaseRequestIntent`만 발행한다.
2. `RecoveryHostRIB` 또는 platform이 새 case 시작 가능 여부를 판단한다.
3. 새 case가 필요하면 기존 child가 직접 다른 feature를 붙이지 않고 case reset 또는 새 recovery 흐름으로 진입한다.

---

## 8. Back / Swipe / Modal 규칙

### 8.1 explicit back

- child가 직접 pop하지 않고 parent owner에게 `back intent`를 올린다.
- owner가 back 가능 여부를 검사한 뒤 pop / detach / no-op을 결정한다.

### 8.2 swipe back / interactive pop

1. interactive pop이 완료되기 전에는 detach하지 않는다.
2. gesture cancel 시 cleanup / detach도 cancel한다.
3. `awaitingExternal`, `pendingDecision`, `securityBlocked`, terminal 직전 상태에서는 swipe back을 기본 금지한다.
4. 서버 action 제출 후 local rollback이 불가능하면 swipe back 대신 명시적 안내를 사용한다.

### 8.3 modal / sheet dismiss

1. modal을 띄운 owner가 dismiss owner다.
2. drag-to-dismiss여도 owner가 최종 dismiss completion으로 detach를 확정한다.
3. dismiss 중 case reset / session reset이 들어오면 modal 완료를 기다리지 않고 상위 owner가 정리한다.

---

## 9. Cleanup 체크리스트

detach는 단순히 view를 빼는 것이 아니다.

반드시 정리할 것:

- `Task`
- timer
- notification observer
- Combine / Rx subscription
- delegate / listener reference
- async sequence consumer
- child router registry
- 임시 draft / write buffer

원칙:

- cleanup은 idempotent 해야 한다.
- double detach가 와도 crash가 나면 안 된다.
- detach 뒤 도착한 late callback은 no-op이어야 한다.

---

## 10. Duplicate Defense 구현 연결점

사양서의 duplicate 방어는 UI debounce만으로 끝나지 않는다.

canonical fingerprint와 first-wins 정책은 메인 사양서의 `Navigation & Shell Spec > interaction / duplicate defense policy`를 따른다.

RIB 구현에서는 아래 지점을 맞춰야 한다.

1. 화면 입력 직후 `View Interaction Lock`
2. owner 진입 직전 `Intent Gate`
3. attach / transition / submit 중 `InFlight Lock`
4. 서버 action 제출 시 idempotency key 보존

unlock은 아래 안정 이벤트 이후에만 허용한다.

- `didShow`
- dismiss completion
- entry attach 완료
- blocking shell stable
- reset completion
- terminal response
- recoverable failure render

---

## 11. Feature 팀 구현 체크리스트

신규 case 추가 시 feature 팀은 아래만 구현한다.

1. `CaseEntry`
2. payload decode
3. `FeatureRecoveryContribution`
4. feature 내부 route spec
5. feature child RIB
6. case 테스트
7. telemetry mapping

최소 체크리스트:

- [ ] `CaseEntry.decodePayload` 구현
- [ ] `CaseEntry.contributeRecovery` 구현
- [ ] feature root builder 등록
- [ ] `RouteFamily` 정의
- [ ] entry model 정의
- [ ] action request / result mapping 정의
- [ ] unit / integration / UI 테스트 추가

---

## 12. 안티패턴

다음은 금지한다.

1. feature A가 feature B builder를 직접 호출
2. child가 자기 자신을 detach한 뒤 parent에 사후 통지
3. interactive pop 시작 시점에 cleanup 먼저 실행
4. `viewDidDisappear`를 detach truth로 해석
5. swipe back으로 서버 제출 이후 step을 롤백
6. modal dismiss와 case reset이 경쟁할 때 둘 다 각각 cleanup
7. callback URL을 feature child가 직접 파싱
8. terminal state를 alert 하나로 축약

---

## 13. 코드 리뷰 질문

1. 이 child의 attach / detach owner가 명확한가?
2. intent와 detach 완료 시점이 분리되어 있는가?
3. gesture cancel 시 구조가 원복되는가?
4. feature 간 직접 import 없이 전환되는가?
5. detach cleanup이 task / observer / timer까지 포함되는가?
6. case reset / session reset이 일반 back flow보다 우선하는가?
7. entry decision이 화면 분기 코드에 흩어져 있지 않은가?
8. duplicate 방어가 버튼 debounce에만 의존하지 않는가?

---

## 14. 최소 테스트 세트

### Unit

- swipe back cancel 시 detach 안 됨
- swipe back complete 시 detach 됨
- double detach no-op
- late callback after detach no-op
- intent gate first-wins 동작

### Integration

- feature A -> feature B 전환이 parent intent를 경유함
- modal dismiss 중 case reset 도착 시 상위 owner가 일관되게 정리함
- pendingDecision 상태에서 swipe back 비활성화
- session reset 중 active child 전체 teardown
- inline push 허용 조건이 아닐 때 shell-first로 승격됨

### UI

- interactive pop 후 이전 화면 포커스 정상
- swipe back disabled 상태에서 사용자 안내 노출
- blocking shell에서 back / swipe 금지

---

## 15. 레퍼런스 코드

설명만으로 부족할 때는 아래 Swift 파일을 함께 본다.

- [`references/ribs-attach-detach-reference.swift`](./references/ribs-attach-detach-reference.swift)

이 파일은 production code가 아니라 아래 정책의 예시다.

- typed intent sink
- feature entry coordinator
- cleanup idempotency
- interactive pop completion ownership
- modal dismiss vs case reset 우선순위
- intent gate first-wins
