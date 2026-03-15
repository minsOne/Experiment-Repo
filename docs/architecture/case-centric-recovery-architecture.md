# Case-Centric Recovery Architecture

- Status: Canonical Spec
- Scope: Enterprise iOS Banking App / RIBs / UIKit / Swift Concurrency / Scoped DI
- Audience: Platform / iOS Feature / QA / Reviewer
- Purpose: 외부 앱 왕복, callback 복귀, delayed or duplicate ingress, session contamination 환경에서도 앱이 서버 authoritative 상태로 수렴하도록 구현 기준을 고정한다.

---

## 0. 문서 위치와 읽는 순서

이 문서는 `docs/architecture`의 단일 기준 사양서다.

- 정책, 데이터 모델, 복구 파이프라인, 서버 계약, 운영/QA 기준은 이 문서를 기준으로 본다.
- RIB 책임, attach/detach, entry model, child-parent 통신, 테스트 체크리스트는 [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)에서 본다.
- 이 구조가 어떤 논의를 거쳐 정제되었는지는 [`case-centric-recovery-architecture-history.md`](./case-centric-recovery-architecture-history.md)에서 본다.
- 코드 스케치는 [`references/ribs-attach-detach-reference.swift`](./references/ribs-attach-detach-reference.swift)에서 본다.

이 문서에서 같은 내용을 구현 가이드 수준으로 반복하지 않는다.

---

## 1. PM Constraints

### Success criteria

1. cold start / warm start / foreground resume / external round-trip / delayed / duplicate / out-of-order callback 환경에서도 앱은 항상 서버 authoritative 상태로 수렴한다.
2. `wrongUser`, `replayDetected`, `expired`, `completedElsewhere`, `pendingDecision`은 일반 오류가 아니라 first-class state로 처리된다.
3. 신규 case 추가 시 수정 지점은 registry, feature plugin, DTO decode, telemetry, test 수준으로 제한된다.
4. recovery 결과는 운영/보안/QA가 재현 가능하고 audit 가능해야 한다.
5. reset은 예외 처리 수단이 아니라 측정 가능하고 통제되는 정책이어야 한다.

### Non-negotiable principles

1. 서버 snapshot이 case truth다.
2. callback은 성공 통지가 아니라 reconcile trigger다.
3. 세션/소유권 검증은 feature 진입보다 먼저 평가한다.
4. feature 간 직접 결합은 금지한다.
5. 운영 관측성과 재현성은 기능 완료 정의에 포함된다.

### Acceptable tradeoffs

- 일부 root or case reset UX 비용 허용
- feature boilerplate 증가 허용
- 초기 설계 복잡도 증가 허용
- 단, 보안 판단 분산, 상태 truth 다원화, 재현 불가능한 복구는 허용하지 않는다

---

## 2. 최종 구조 요약

채택 구조는 다음이다.

> **Case-Centric Recovery Architecture with Deterministic Recovery Pipeline**

핵심은 아래 여섯 가지다.

1. Recovery Decision과 Recovery Execution을 분리한다.
2. Session Security Gate를 feature 앞단의 고정 단계로 올린다.
3. `SessionRuntimeActor`와 `CaseRuntimeActor`의 2단 직렬화를 둔다.
4. Shell State를 공통 UX 계약으로 명세화한다.
5. `CaseEntry`는 만능 orchestrator가 아니라 제한된 plugin으로 둔다.
6. 운영, 배포, 롤백 규칙을 아키텍처 사양 범위 안에 포함한다.

---

## 3. 핵심 설계 판단

### ADR-01. Truth Source

- Truth: `CaseSnapshot`
- Local ephemeral state: `CaseRuntimeState`
- Navigation and UI tree는 truth가 아니라 execution 결과다

### ADR-02. Recovery Ownership

- Feature는 자신의 업무 상태와 feature route만 제안한다.
- 보안, 세션, terminal, global reset 결정은 platform이 소유한다.
- 따라서 `CaseEntry`는 제한된 권한의 plugin이어야 한다.

### ADR-03. Deterministic Recovery

모든 복구는 아래 파이프라인으로만 처리한다.

`Ingress -> Normalize -> Dedupe -> SessionBindCheck -> Reconcile -> Decision -> Execute -> Observe`

중간 단계를 우회하는 direct feature callback 처리는 금지한다.

### ADR-04. Reset Governance

reset은 허용 여부가 아니라 정책 엔진 결과다.

- `inPlace`
- `caseReset`
- `sessionReset`

각 결과는 reason code와 telemetry를 반드시 남긴다.

### ADR-05. Banking-grade Auditability

운영자는 PII 없이도 case timeline을 복원할 수 있어야 한다.

- sanitized replay 가능
- decision reason code 보존
- drop, discard, stale 처리까지 모두 이벤트 기록

---

## 4. 아키텍처 레이어

1. External Ingress Platform
2. Session & Security Platform
3. Case Runtime Platform
4. Recovery Decision Platform
5. Navigation & Shell Platform
6. Observability & Operations Platform
7. Feature Modules

### 레이어 책임

| Layer | Responsibility | 금지 사항 |
|---|---|---|
| External Ingress | 외부 이벤트 정규화, 채널 식별, dedupe 입력 생성 | feature 직접 호출 |
| Session & Security | 로그인 세션 상태, user binding, contamination 판단 | feature route 결정 |
| Case Runtime | case별 직렬화, epoch/version 관리, reconcile lifecycle 관리 | 화면 조립 |
| Recovery Decision | snapshot + runtime + registry 기반으로 plan 생성 | 직접 UI 실행 |
| Navigation & Shell | reset/push/present 수행, shell 렌더링 | business truth 저장 |
| Observability & Operations | timeline/event/audit/kill switch/SLO | feature 로직 관장 |
| Feature Modules | payload decode, local flow route, local action | 다른 feature import |

---

## 5. 핵심 모델

### 5.1 CaseSnapshot

```swift
public struct CaseSnapshot: Sendable {
    let caseId: String
    let caseType: CaseType
    let lifecycleState: LifecycleState
    let stateVersion: Int64
    let ownershipBinding: OwnershipBinding
    let allowedActions: [CaseAction]
    let customerMessageCode: String?
    let serverTimestamp: Date
    let payload: Data
}
```

규칙:

- 서버 snapshot만이 case truth다.
- `stateVersion`은 동일 case에서 감소하면 안 된다.
- 앱은 snapshot이 없거나 오래된 로컬 route를 truth처럼 사용하면 안 된다.

### 5.2 DecisionEvidence

```swift
public struct DecisionEvidence: Sendable {
    let reasonCode: String
    let policyVersion: String
    let ingressChannel: IngressChannel
    let dedupeDisposition: DedupeDisposition
}
```

규칙:

- 모든 recovery 결정은 `DecisionEvidence`를 남긴다.
- 운영 trace, QA replay, 감사 로그는 같은 reason code space를 공유한다.

### 5.3 CaseRuntimeState

```swift
public struct CaseRuntimeState: Sendable {
    let caseId: String
    let activeEpoch: Int64
    let lastExecutedRouteFamily: RouteFamily?
    let shellState: ShellState
    let pendingIngressFingerprint: String?
}
```

규칙:

- runtime state는 snapshot을 대체하지 않는다.
- detach 이후 late callback을 무효화할 수 있도록 epoch를 가진다.

### 5.4 RecoveryDecision

```swift
public struct RecoveryDecision: Sendable {
    let shellState: ShellState
    let executionPolicy: ExecutionPolicy
    let featureRoute: FeatureRoute?
    let blockingReason: BlockingReason?
    let evidence: DecisionEvidence
}
```

### 5.5 FeatureRecoveryContribution

```swift
public struct FeatureRecoveryContribution: Sendable {
    let routeFamily: RouteFamily
    let preferredRoute: FeatureRoute?
    let localActions: [FeatureAction]
}
```

규칙:

- feature contribution은 `securityRejected`와 `sessionReset`를 직접 만들 수 없다.
- feature contribution은 다른 feature type을 참조할 수 없다.
- route는 `RouteFamily`로 표준화되어 reset 판단 입력으로만 사용한다.

### 5.6 CaseEntry

```swift
public protocol CaseEntry: Sendable {
    var caseType: CaseType { get }
    func decodePayload(_ snapshot: CaseSnapshot) throws -> FeaturePayload
    func contributeRecovery(
        snapshot: CaseSnapshot,
        runtime: CaseRuntimeState
    ) -> FeatureRecoveryContribution
}
```

`CaseEntry`는 feature 권한을 plugin 경계 안으로 제한하기 위해 존재한다.

---

## 6. Runtime 직렬화 모델

### 6.1 SessionRuntimeActor

- session 경계 직렬화 owner
- login/logout/session contamination 처리
- `sessionReset` 시 subtree 재구성의 시작점

### 6.2 CaseRuntimeActor

- case별 직렬화 owner
- 동일 case ingress의 순서 보장
- active epoch, in-flight guard, late event discard 관리

### 6.3 동작 규칙

1. Session 관련 이벤트는 `SessionRuntimeActor`에서 먼저 직렬화한다.
2. case 관련 이벤트는 `CaseRuntimeActor`에서 직렬화한다.
3. 동일 case에 대한 reconcile은 동시 실행하지 않는다.
4. stale snapshot, stale callback, 늦은 completion은 현재 epoch와 맞지 않으면 discard한다.
5. scene destruction, case reset, session reset은 actor teardown과 함께 기록된다.

### 6.4 이벤트 우선순위

우선순위는 아래 순서를 따른다.

1. `sessionReset`
2. ownership mismatch or security block
3. `caseReset`
4. terminal transition
5. in-place refresh
6. low-priority poll or retry

### 6.5 Deferred Execution Checkpoint

다음 이벤트는 실행 전에 checkpoint를 다시 확인한다.

- external return 직후
- scene foreground 복귀
- long-running pending decision poll 완료
- UI submit 응답 수신 직후

### 6.6 Runtime Ownership and Teardown

- `SessionRootRIB`는 `SessionRuntimeActor`의 owner다.
- `CaseShellRIB`는 `CaseRuntimeActor`의 owner다.
- `CaseContainer` 파기 시 case actor, observer, timer, cleanup bag을 모두 정리한다.

### 6.7 Multi-scene 강제 정책

- primary recovery scene 하나만 write lock을 가진다.
- secondary scene은 recovery truth를 직접 변경하지 않는다.
- secondary scene에서 들어온 ingress는 primary recovery owner로 전달하거나 읽기 전용 shell만 보여준다.

---

## 7. External Ingress 표준

### IngressEnvelope

```swift
public struct IngressEnvelope: Sendable {
    let ingressId: String
    let channel: IngressChannel
    let receivedAt: Date
    let caseId: String?
    let sessionHint: String?
    let payload: Data
}
```

### 정규화 규칙

1. app scheme, universal link, push, polling completion은 모두 `IngressEnvelope`로 정규화한다.
2. transport 레벨 차이는 여기서 제거하고 recovery 단계에 feature-specific 분기를 넘기지 않는다.
3. ingress는 수신 즉시 trace event를 남긴다.

### PendingIngressStore

- app이 background에 있을 때 수신한 ingress를 임시 저장한다.
- session bind 검증 전에는 feature에 전달하지 않는다.
- stale or duplicate ingress는 replay 가능하게 기록하되 실행은 차단한다.

---

## 8. Session & Security Gate

### OwnershipBinding

```swift
public struct OwnershipBinding: Sendable {
    let userIdHash: String
    let deviceBindingId: String?
    let authSessionId: String
}
```

### SecurityDisposition

- `allowed`
- `safeLandingRequired`
- `securityBlocked`
- `sessionResetRequired`

### 규칙

1. ownership 검증은 feature 진입보다 먼저 수행한다.
2. 현재 세션과 snapshot binding이 다르면 feature route 계산을 하지 않는다.
3. `securityBlocked`와 `safeLandingRequired`는 일반 오류가 아니라 shell state로 보여준다.
4. session contamination은 `sessionReset` policy를 강제한다.

### Safe Landing

- 이전 사용자 데이터 노출 없이 안전한 홈 or 로그인 진입을 제공한다.
- 이유 설명은 고객-facing 정책 문구로 제한하고 raw security detail은 노출하지 않는다.

---

## 9. Recovery Decision Engine

### 입력

- `CaseSnapshot`
- `CaseRuntimeState`
- `OwnershipBinding`
- `CaseEntry`
- `DecisionPolicy`
- `IngressEnvelope`

### 출력 규칙

#### Terminal states

- `completed`
- `completedElsewhere`
- `expired`
- `cancelled`

terminal state는 feature child보다 shell state가 우선한다.

#### Non-terminal states

- `recovering`
- `actionRequired`
- `pendingDecision`
- `securityBlocked`
- `safeLanding`

### Decision restrictions

- feature contribution은 `securityRejected`와 `sessionReset`를 직접 만들 수 없다.
- shell state와 execution policy는 policy engine이 최종 결정한다.
- decision은 execution 전에 observability payload를 같이 생성해야 한다.

---

## 10. Navigation & Shell Spec

### 표준 ShellState

- `recovering`
- `actionRequired`
- `pendingDecision`
- `completed`
- `completedElsewhere`
- `expired`
- `cancelled`
- `securityBlocked`
- `safeLanding`

### ShellContentSpec

```swift
public struct ShellContentSpec: Sendable {
    let titleKey: String
    let bodyKey: String
    let primaryAction: ShellAction?
    let secondaryAction: ShellAction?
    let expectedNextStepKey: String?
    let accessibilityAnnouncementKey: String
    let supportPolicyRef: String?
}
```

### 상태별 Shell 계약

| ShellState | 필수 노출 | 기본 CTA 규칙 | 금지 규칙 |
|---|---|---|---|
| recovering | 현재 처리 중, 입력 잠금 이유, 다음 갱신 방식 | 없음 또는 취소 불가 안내 | 성공/실패 확정 문구 |
| pendingDecision | 예상 대기 성격, 수동 새로고침 가능 시점, 고객지원 조건 | 새로고침/닫기/지원 안내 중 정책 허용된 것만 | 무한 spinner 단독 노출 |
| completedElsewhere | 다른 채널 처리 완료 안내, 추가 입력 차단 이유 | 결과 보기 또는 확인 | 동일 case 재입력 유도 |
| expired | 만료 이유 범주, 재시작 가능 여부 | 재시작 또는 확인 | 기존 데이터가 남아 있는 것처럼 보이는 UX |
| securityBlocked | 보안상 제한됨, 다음 안전한 행동, 지원 연결 조건 | 재인증 또는 확인 또는 지원 연결 | raw 보안 내부 사유 직접 노출 |
| safeLanding | 현재 상태를 안전하게 확인 중임, 데이터 노출 제한 사유 | 홈/로그인/지원 중 하나 | 이전 사용자/다른 case 정보 노출 |

### UX 규칙

1. 외부 앱 호출 직전 화면은 언제든 detach 가능해야 한다.
2. 복귀 직후 사용자가 보게 되는 첫 상태는 기존 feature 임시 화면이 아니라 shell-safe 상태여야 한다.
3. reset이 일어나도 앱이 튕긴 것처럼 보이면 안 된다.
4. `pendingDecision`은 다음 기대 행동과 예상 대기 정보를 제공해야 한다.
5. `caseReset`과 `sessionReset`은 각각 다른 사용자 의미를 보여줘야 한다.

### 접근성 기준

- shell 상태 화면은 Dynamic Type 접근성 크기까지 레이아웃이 유지되어야 한다.
- 첫 포커스는 제목 또는 핵심 안내에 위치해야 한다.
- 상태 전환 시 `accessibilityAnnouncementKey`는 1회만 재생되어야 한다.
- 주요 CTA는 최소 44x44pt 터치 영역을 가진다.

### RIB 통합 계약

- 표준 RIB tree와 attach/detach ownership은 [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)를 따른다.
- 이 문서는 shell state와 execution policy만 고정하고, 구체 라우팅 구현은 구현 가이드로 넘긴다.

### reset rules

| Policy | Allowed when | UI rule |
|---|---|---|
| inPlace | 동일 session, 동일 case, 동일 route family | 기존 shell 유지 후 콘텐츠 교체 |
| caseReset | 동일 session이나 현재 tree가 결정과 불일치 | shell 먼저 고정 후 feature 재구성 |
| sessionReset | session changed, ownership mismatch, root contamination | feature 전부 분리 후 session shell 재구성 |

### entry policy

| 모델 | 기본 적용 조건 | 정책 가드레일 |
|---|---|---|
| `shellFirstAuthoritative` | external return, deep link, cold start, foreground resume, blocked/pending/terminal 가능성 존재 | 기본값, shell-safe 상태를 먼저 고정 |
| `inlinePushContinuation` | 동일 session, 동일 case, 동일 route family, authoritative fetch 불필요 | 제한적 예외, 불확실성 있으면 shell-first로 승격 |
| `auxiliaryLocalEntry` | 주소 검색, 도움말, picker, 문서 미리보기 같은 보조 흐름 | recovery truth를 바꾸지 않음 |

- entry decision은 화면이나 child RIB가 분산 소유하지 않는다.
- coordinator 성격의 단일 owner가 policy를 적용하고, 구체 구현은 [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)에서 정의한다.

### interaction / duplicate defense policy

duplicate 방어는 UI debounce 하나로 끝나는 문제가 아니다.

canonical fingerprint는 아래 필드를 함께 본다.

`(intentKind, ownerId, caseId/sessionId, routeFamily, targetId, payloadHash, epoch)`

정책 규칙:

1. 같은 owner와 active epoch 안에서는 first-wins를 기본값으로 한다.
2. 같은 fingerprint의 후속 intent는 no-op 처리하되 trace와 telemetry에는 남긴다.
3. 방어 계층은 `View Interaction Lock -> Intent Gate -> InFlight Lock -> Server Idempotency Key` 순으로 겹쳐 둔다.
4. unlock은 안정 이벤트 이후에만 허용한다.

안정 이벤트 기준:

- `didShow`
- dismiss completion
- entry attach 완료
- blocking shell stable
- reset completion
- terminal response
- recoverable failure render

---

## 11. DI / Composition Rules

### 컨테이너 계층

- `AppContainer`
- `SessionContainer`
- `CaseContainer`
- `RIBBuildScope`

### 필수 규칙

1. `CaseContainer`는 case 종료, session reset, ownership mismatch 시 즉시 파기한다.
2. `CaseContainer`는 다른 user session에서 재사용할 수 없다.
3. actor mutable state를 container singleton에 저장하면 안 된다.
4. DI는 생명주기 관리만 담당하고 snapshot truth를 캐시하면 안 된다.
5. feature builder는 자신이 속한 case contract만 주입받는다.

### Lifecycle Matrix

| Event | SessionContainer | CaseContainer | SessionRuntimeActor | CaseRuntimeActor | RecoveryHost | CaseShell |
|---|---|---|---|---|---|---|
| cold start, no pending case | 생성 | 없음 | 생성 | 없음 | attach | 없음 |
| case 시작 | 유지 | 생성 | 유지 | 생성 | 유지 | attach |
| inPlace recovery | 유지 | 유지 | 유지 | 유지 | 유지 | 유지 |
| caseReset | 유지 | 파기 후 재생성 | 유지 | 재생성 | 유지 | detach 후 re-attach |
| sessionReset | 파기 후 재생성 | 전부 파기 | 재생성 | 전부 종료 | detach 후 재구성 | 전부 detach |
| terminal ack 후 종료 | 유지 | 파기 | 유지 | 종료 | 유지 | detach |

### 금지 패턴

- global mutable store로 recovery 결정을 공유하는 것
- platform singleton이 feature payload decode를 수행하는 것
- common module에 caseType 분기를 계속 누적하는 것
- builder가 session/security 판단을 수행하는 것

---

## 12. 서버 계약

### 필수 API 계약

| API | 추가 필수 필드 |
|---|---|
| `POST /cases` | `contractVersion`, `ownershipBinding`, `nextAllowedPollAt?` |
| `GET /cases/{caseId}` | `stateVersion`, `ownershipBinding`, `serverTimestamp`, `contractVersion` |
| `POST /cases/reconcile` | `decisionReason`, `ownershipBinding`, `securityReason`, `decisionEvidence`, `customerMessageCode`, `stateVersion`, `serverTimestamp` |
| `POST /cases/{caseId}/actions` | `stateVersion`, `allowedActions`, `nextAllowedPollAt?`, `idempotencyKey?` |
| `GET /cases/{caseId}/pending-decision` | `pendingReason`, `nextPollAfter`, `estimatedResolutionWindow?` |
| `GET /cases/{caseId}/result` | `resultSummary`, `receipt`, `finalizedAt` |

### 계약 규칙

1. `stateVersion`은 동일 case에서 감소하면 안 된다.
2. `ownershipBinding`은 모든 recovery 관련 응답에 포함된다.
3. `contractVersion` mismatch 시 앱은 feature 진입 대신 fallback shell을 노출한다.
4. `decisionReason`은 telemetry event와 같은 code space를 쓴다.
5. `pendingDecision`은 무한 spinner를 막기 위해 `nextPollAfter`를 포함해야 한다.
6. `decisionEvidence.policyVersion`은 운영과 감사 재현에 사용되므로 누락될 수 없다.
7. submit 계열 action은 중복 방지를 위해 idempotency 계약을 가져야 한다.

---

## 13. 관측성 / 운영 규격

### 필수 이벤트

- `ingress_received`
- `ingress_deduped`
- `session_binding_evaluated`
- `reconcile_started`
- `reconcile_succeeded`
- `reconcile_discarded_stale`
- `recovery_decision_made`
- `recovery_execution_started`
- `recovery_execution_completed`
- `shell_state_rendered`
- `reset_applied`
- `duplicate_intent_dropped`
- `submit_idempotency_applied`

### 공통 필드

- `traceId`
- `sessionIdHash`
- `caseId`
- `caseType`
- `stateVersion`
- `policy`
- `shellState`
- `reasonCode`
- `ingressChannel`
- `epoch`

### Golden Event Trace Contract

운영과 QA는 아래 순서를 재구성할 수 있어야 한다.

`ingress_received -> session_binding_evaluated -> reconcile_started -> recovery_decision_made -> recovery_execution_started -> shell_state_rendered -> recovery_execution_completed`

규칙:

- drop, stale, duplicate, no-op도 trace에서 사라지면 안 된다.
- PII 없이도 동일 case timeline을 복원할 수 있어야 한다.

### 운영 기능

- sanitized replay
- decision reason drill-down
- kill switch for ingress channel
- pending decision escalation monitoring

### Trace / Replay 보존 정책

- 보존 기간은 보안/컴플라이언스 정책과 일치해야 한다.
- replay payload는 masking된 형태로만 유지한다.

### 초기 운영 임계치

- `returned_to_shell / external_handoff_started >= 99%`
- `action_resumed / returned_to_shell >= 95%`
- stale discard 급증 시 알림
- duplicate intent drop 급증 시 UI regressions 점검

### 운영 Runbook 연결

- support escalation 기준
- safe landing fallback 절차
- session contamination incident 대응 절차

### SLO / Release gate

- shell state regression 없음
- replay 기반 핵심 시나리오 재현 가능
- 주요 reset 경로 trace 누락 없음

---

## 14. 테스트 전략

### Unit

- `CaseEntry.decodePayload`
- `CaseEntry.contributeRecovery`
- decision policy matrix
- dedupe fingerprint 생성
- stateVersion and epoch discard 규칙

### Contract

- server field completeness
- `ownershipBinding`, `contractVersion`, `decisionReason`
- idempotency key and pending decision 계약

### Integration

- cold start 복구
- external round-trip 복귀
- wrong-user callback
- delayed or duplicate callback
- `caseReset` and `sessionReset`

### UI

- shell state 전환
- external handoff 직전/직후
- blocking state 표시
- Dynamic Type and VoiceOver

### Architecture Fitness Tests

- feature direct import 금지
- common module의 caseType switch 확장 금지
- navigation tree를 truth로 쓰는 코드 금지

### Invariant Test Set

- 단일 active case recovery 흐름
- stale event discard
- reset policy telemetry 기록

### Scenario Matrix Release Gate

- `cold/warm/resume/external return`
- `duplicate/delayed/out-of-order`
- `wrong-user/expired/completedElsewhere/pendingDecision`
- `caseReset/sessionReset`

### Test Data / Masking 규칙

- replay 가능한 데이터는 masking된 fixture만 허용한다.

---

## 15. 구현 로드맵

1. ingress normalization과 session gate를 먼저 고정한다.
2. decision engine과 shell contract를 도입한다.
3. `CaseEntry` registry와 feature plugin 경계를 정리한다.
4. RIB 구현 가이드 기준으로 recovery host, case shell, feature child 경계를 맞춘다.
5. observability, replay, release gate를 붙인다.

---

## 16. 품질 게이트

1. 기준 문서는 이 파일 하나여야 한다.
2. 구현 가이드는 이 문서의 정책을 재정의하지 않고 구체화만 해야 한다.
3. 신규 case는 registry, plugin, telemetry, test 외에 platform 수정이 필요 없음을 리뷰에서 증명해야 한다.
4. QA는 golden trace만으로 핵심 시나리오를 재현할 수 있어야 한다.
5. security and compliance 문구는 shell message governance를 통과해야 한다.

---

## 17. 비채택안과 탈락 사유

### 비채택안 A. Feature가 직접 callback 처리

- session/security gate를 우회하게 되어 탈락

### 비채택안 B. CaseEntry가 전체 RecoveryPlan 생성

- plugin 권한이 과도해져 탈락

### 비채택안 C. Global App Store 중심 복구

- state truth가 다원화되고 case 경계가 약해져 탈락

### 비채택안 D. Navigation stack 복원 중심 설계

- VC stack 생존을 truth처럼 가정하게 되어 탈락

---

## 18. 잔여 불확실성과 통제 방식

- multi-scene 상세 UX는 제품 정책에 따라 더 구체화가 필요하다.
- support escalation copy는 운영 조직과의 합의가 필요하다.
- polling window와 pendingDecision 장기화 기준은 운영 데이터로 미세 조정해야 한다.

위 항목은 설계 불확실성이지 truth source 자체를 흔드는 쟁점은 아니다.

---

## 19. 최종 구현 기준

아래 질문에 모두 `yes`여야 한다.

1. recovery truth가 `CaseSnapshot` 하나로 수렴하는가
2. session/security 판단이 feature 앞단에 고정되어 있는가
3. reset이 `inPlace`, `caseReset`, `sessionReset` 세 정책으로 설명되는가
4. shell state와 trace만으로 운영/QA가 재현 가능한가
5. feature가 다른 feature를 직접 attach/import하지 않는가
6. 상세 RIB 규칙이 [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)와 일치하는가

하나라도 `no`면 본 구조는 미완성이다.
