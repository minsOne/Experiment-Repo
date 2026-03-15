# Architecture Docs

`docs/architecture`는 Case-Centric Recovery Architecture와 RIBs 구현 규칙을 아래 5개 문서로 정리한다.

| 문서 | 역할 | 언제 먼저 읽는가 |
|---|---|---|
| [`case-centric-recovery-architecture.md`](./case-centric-recovery-architecture.md) | 최종 구현 기준 사양서 | 정책, 계약, 품질 게이트를 확인할 때 |
| [`ribs-implementation-guide.md`](./ribs-implementation-guide.md) | RIB 구조와 attach/detach 구현 가이드 | iOS 구현과 코드 리뷰 기준이 필요할 때 |
| [`case-centric-recovery-architecture-history.md`](./case-centric-recovery-architecture-history.md) | 왜 이런 결정을 했는지 남긴 설계 기록 | 배경, 선택 이유, 과거 논의를 확인할 때 |
| [`references/ribs-attach-detach-reference.swift`](./references/ribs-attach-detach-reference.swift) | 문서 정책을 코드 스케치로 보여주는 레퍼런스 | 실제 RIB 코드 형태를 빠르게 감 잡을 때 |
| [`README.md`](./README.md) | 문서 진입점 | 처음 구조를 파악할 때 |

## 추천 읽기 순서

### 처음 읽는 사람

1. `README.md`
2. `case-centric-recovery-architecture.md`
3. `ribs-implementation-guide.md`

### 구현 중인 iOS 엔지니어

1. `case-centric-recovery-architecture.md`
2. `ribs-implementation-guide.md`
3. `references/ribs-attach-detach-reference.swift`

### 리뷰어 / QA / 운영

1. `case-centric-recovery-architecture.md`
2. `case-centric-recovery-architecture-history.md`

## 정리 원칙

1. 기준 문서는 하나만 둔다.
2. 구현 규칙은 RIB 가이드로 모으고, 사양서에는 정책 수준의 기준만 남긴다.
3. 설계 배경과 결정 기록은 별도 문서로 남겨, 사양서가 역사 서술로 비대해지지 않게 한다.
4. Swift 레퍼런스는 설명용 예시이며 production code truth가 아니다.

## 이번 정리에서 흡수된 내용

- 기존 `case-centric-recovery-architecture.md` 초안은 최종 사양서와 설계 기록으로 흡수했다.
- 기존 `case-centric-recovery-architecture-refined-spec.md`는 최종 사양서로 통합했다.
- 기존 `ribs-usage-guide.md`와 `ribs-attach-detach-patterns.md`는 `ribs-implementation-guide.md`로 통합했다.
- 기존 대화 요약 문서는 `case-centric-recovery-architecture-history.md`로 축약 정리했다.
