# Case-Centric Recovery Architecture History

- Status: Design Record
- Audience: PM / Platform / iOS / QA / Reviewer
- Purpose: 현재 최종 사양과 RIB 가이드가 어떤 논점을 거쳐 구체화되었는지, 무엇을 버리고 무엇을 남겼는지 기록한다.
- Canonical Spec: [`case-centric-recovery-architecture.md`](./case-centric-recovery-architecture.md)
- Implementation Guide: [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)

---

## 1. 왜 별도 기록이 필요한가

기존 문서군에는 아래 3종의 내용이 섞여 있었다.

1. 문제의식과 방향성
2. 실제 구현 기준
3. 대화 과정에서 나온 결정 배경

이 셋을 한 파일에 두면 기준 문서가 흔들리고, 반대로 전부 지우면 왜 그런 제약을 두었는지 잃어버린다.

이 문서는 그 사이를 메운다.

---

## 2. 출발점과 한계

출발점이었던 기존 초안은 좋은 방향을 이미 갖고 있었다.

- 서버 authoritative 지향
- callback을 reconcile trigger로 보는 시각
- feature direct import 금지
- VC stack 생존 가정 금지
- scoped DI 지향

하지만 구현 기준으로 쓰기에는 아래가 비어 있었다.

- reset 정책의 구체 기준
- session / security gate의 고정 위치
- attach / detach / back / swipe ownership
- 운영 trace / replay / 감사 가능성
- shell UX 계약과 접근성 기준
- 테스트 / release gate
- duplicate / stale / late event 방어

---

## 3. 1차 수렴: 추상 원칙을 결정 파이프라인으로 고정

가장 큰 전환은 아래 한 줄이었다.

> `Ingress -> Normalize -> Dedupe -> SessionBindCheck -> Reconcile -> Decision -> Execute -> Observe`

이 시점부터 바뀐 점:

- callback 직접 성공 처리 금지
- `CaseSnapshot`을 truth로 승격
- `RecoveryDecision`과 실행 분리
- `inPlace / caseReset / sessionReset`을 정책 엔진 결과로 고정
- trace, replay, 운영 임계치를 아키텍처 범위에 포함

이 결정은 최종 사양서의 핵심 축이 되었다.

---

## 4. 2차 수렴: RIB를 별도 구현 가이드로 분리

메인 사양서에 RIB 구현 세부를 계속 추가하면 두 문제가 생겼다.

1. 정책 문서가 iOS 구현 세부로 과밀해진다.
2. feature 팀이 실제로 찾아야 하는 규칙이 흩어진다.

그래서 RIB 관련 내용은 별도 구현 가이드로 분리했다.

최종적으로 남긴 최소 기준은 다음이었다.

- `CaseShellRIB`는 case 복구의 안정 부모다.
- `FeatureChildRIB`는 업무 UI와 로컬 action만 담당한다.
- session / security / reset / terminal 결정은 feature child가 소유하지 않는다.
- attach / detach / reset 순서는 deterministic 해야 한다.

---

## 5. 3차 수렴: attach / detach / back / swipe를 ownership 문제로 재정의

초기에는 화면 전환과 detach가 섞여 있었다.

정리 후 핵심은 아래였다.

> owner가 attach하고 owner가 detach한다.

이 결정으로 고정된 규칙:

- child는 detach intent만 올릴 수 있고 자기 자신을 최종 detach하지 않는다.
- swipe back은 UI 이벤트일 뿐, truth 변경 수단이 아니다.
- interactive pop은 완료 후에만 구조 변경을 확정한다.
- modal dismiss와 case reset이 경쟁하면 상위 owner가 우선 정리한다.
- feature A가 feature B를 직접 호출하지 않고, parent intent 또는 cross-case intent로 요청한다.

이 내용은 현재 [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)에 통합되어 있다.

---

## 6. 4차 수렴: child -> parent 통신 방식을 하이브리드 표준으로 정리

논점은 단순히 delegate를 쓸지 말지가 아니었다.

실제 분해 결과는 아래 3종이었다.

| 종류 | 권장 수단 | 이유 |
|---|---|---|
| 구조적 child -> parent 신호 | `typed IntentSink` | ownership과 topology 변경이 걸려 있음 |
| same-case leaf one-shot completion | `Closure` | 짧고 국소적이며 구조 변경이 없음 |
| stream / lifecycle / late event / serialization | Swift Concurrency | 직렬화와 비동기 처리 경계가 필요함 |

정리 과정에서 나온 금지 기준:

- raw `AsyncStream`으로 topology를 직접 바꾸지 않는다.
- closure로 case reset, cross-case transition, security 판단을 우회하지 않는다.
- detach 뒤 도착한 completion은 no-op이어야 한다.

이 내용은 최종 RIB 가이드의 통신 규칙에 반영했다.

---

## 7. 5차 수렴: 기능 진입 방식을 3개 entry model로 축소

처음에는 기능 진입이 너무 여러 방식으로 보였다.

- 선조회 후 진입
- 선조회 없이 진입
- 기존 화면에서 push 진입
- shell을 거친 진입

최종적으로는 아래 3개만 남겼다.

1. `shellFirstAuthoritative`
2. `inlinePushContinuation`
3. `auxiliaryLocalEntry`

핵심 결정:

- shell-first가 기본값이다.
- inline push는 same-case / same-route-family / 즉시 actionable / authoritative fetch 불필요일 때만 예외 허용이다.
- auxiliary는 본 기능 진입 모델과 분리한다.
- 화면이 직접 분기하지 않고 `FeatureEntryCoordinator`가 entry decision을 소유한다.

이 결정은 spec의 navigation / entry 정책과 guide의 구현 규칙으로 흡수했다.

---

## 8. 6차 수렴: 따닥 방지를 4계층 정책으로 고정

버튼 debounce만으로는 중복 실행을 막을 수 없었다.

최종 정책은 아래 4계층이다.

1. `View Interaction Lock`
2. `Intent Gate`
3. `InFlight Lock`
4. `Submit Idempotency`

중복 판정 fingerprint:

`(intentKind, ownerId, caseId/sessionId, routeFamily, targetId, payloadHash, epoch)`

핵심 운영 규칙:

- navigation intent는 `first-wins`, 나머지는 `drop + trace`
- submit intent는 `first-wins + idempotency`
- retry는 explicit unlock 후에만 허용
- unlock은 `didShow`, dismiss completion, reset completion, terminal response, recoverable failure render 같은 안정 이벤트 이후에만 허용

이 내용은 최종 사양서에 별도 interaction / duplicate defense 섹션으로 올렸다.

---

## 9. 이번 통합에서 남긴 문서 세트

### 9.1 기준 문서

- [`case-centric-recovery-architecture.md`](./case-centric-recovery-architecture.md)

담당 범위:

- 정책
- 데이터 모델
- pipeline
- 서버 계약
- 운영 / QA / release gate
- entry / duplicate defense

### 9.2 구현 가이드

- [`ribs-implementation-guide.md`](./ribs-implementation-guide.md)

담당 범위:

- RIB tree와 책임
- attach / detach / back / swipe / modal
- 통신 규칙
- feature 구현 체크리스트
- 리뷰 질문과 최소 테스트

### 9.3 설계 기록

- [`case-centric-recovery-architecture-history.md`](./case-centric-recovery-architecture-history.md)

담당 범위:

- 왜 이런 구조가 되었는지
- 어떤 논점을 어떻게 축소했는지
- 버린 안과 남긴 안의 이유

### 9.4 코드 레퍼런스

- [`references/ribs-attach-detach-reference.swift`](./references/ribs-attach-detach-reference.swift)

담당 범위:

- intent sink
- entry coordinator
- attach / detach ownership
- interactive pop
- duplicate gate

---

## 10. 한 줄 결론

이 설계는 “복잡도를 없애는 문서”가 아니라,

> 복잡도를 deterministic pipeline, stable shell, explicit ownership, auditable trace 안에 가두는 문서 체계

로 수렴했다.
