# 시나리오 검증 결과 (시뮬레이터 런 결과 반영)

- 기준: 앱 로그(`StandardOutputAndStandardError-com.dismissprobe.demo.txt`)의 `viewDidDisappear` 이벤트로 판정  
- 수집 채널: iOS 시뮬레이터 테스트 로그  
- 디바이스/OS: iPhone 17 / iOS 26.2  
- 수집일시: 2026-03-05 00:34~00:39 (KST)
- 비고: 일부 시나리오는 테스트 자동화 시점에서 이벤트 미수집으로 `X` 표시

| 실행일시 | 디바이스 | iOS | 시나리오 | isBeingDismissed | isMovingFromParent | view.window == nil | viewDidDisappear | 감지 판정 |
|---|---|---|---|---|---|---|---|---|
| 2026-03-05 00:34:35 | iPhone 17 | 26.2 | 1. Modal dismiss (코드) | `true` | `false` | `true` | 존재 | `PASS` |
| 2026-03-05 00:34:45 | iPhone 17 | 26.2 | 2. 스와이프 dismiss | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집) |
| 2026-03-05 00:35:00 | iPhone 17 | 26.2 | 3. 스와이프 취소 | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집/기대치 불일치) |
| 2026-03-05 00:34:53 | iPhone 17 | 26.2 | 4. Nav pop | `false` | `true` | `true` | 존재 | `PASS` |
| 2026-03-05 00:35:00 | iPhone 17 | 26.2 | 5-1. NavController dismiss A | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집) |
| 2026-03-05 00:35:00 | iPhone 17 | 26.2 | 5-2. NavController dismiss B | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집) |
| 2026-03-05 00:35:02 | iPhone 17 | 26.2 | 5-3. NavController dismiss C | `false` | `false` | `true` | 존재 | `PASS` |
| 2026-03-05 00:35:14 | iPhone 17 | 26.2 | 6-1. popToRoot A | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집) |
| 2026-03-05 00:35:14 | iPhone 17 | 26.2 | 6-2. popToRoot B | `-` | `-` | `-` | `N/A` | `FAIL` (이벤트 미수집) |
| 2026-03-05 00:35:16 | iPhone 17 | 26.2 | 6-3. popToRoot C | `false` | `true` | `true` | 존재 | `PASS` |
| 2026-03-05 00:35:35 | iPhone 17 | 26.2 | 7. 오탐 방지 (present overlay) | `-` | `-` | `not false`(중간상태 없음), `true` at final dismiss sequence | `N/A` / `존재` | `PASS` (중간 오탐 없음) |

## 기대치(사전 정의)

- 1: `true / false / true`
- 2: `true / false / true`
- 3: `viewDidDisappear 미호출`
- 4: `false / true / true`
- 5: `A/B/C 모두 false / false / true`
- 6: `A,B false / false / true`, `C false / true / true`
- 7: `view.window != nil`, `viewDidDisappear 미호출`

## 로그 확인 체크 포인트

- 시나리오 버튼 탭 직후 루트 버튼 복귀 확인
- 각 시나리오 종료 후 해당 VC 이름 이벤트 존재 여부 확인
- 오탐 방지(7): overlay가 떠있는 구간에서도 하위 VC 이벤트가 비정상적으로 발생하지 않는지 확인

## 공유용 정리용 메모

- 본 템플릿은 `Run + run_ui_tests.sh`를 통해 생성된 시뮬레이터 로그 기반 샘플 기록입니다.
- 실기기 재실행 시 동일 행 형태로 누적 비교하면 기기/OS별 편차를 정량 비교할 수 있습니다.
