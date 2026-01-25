# RIBs + Swift Concurrency 통합 패턴

## 발표 자료

---

## 📋 목차

1. 문제 정의
2. 기존 RIBs 패턴 (Delegate/Listener)
3. Closure 기반 패턴으로 전환
4. Swift Concurrency 통합
5. 최종 아키텍처
6. 실전 예제
7. 장단점 분석

---

## 1️⃣ 문제 정의

### RIBs 아키텍처의 과제

**기존 문제점:**
- Listener Protocol의 과도한 사용
- 부모 Interactor가 모든 자식의 Listener를 구현해야 함
- 비동기 작업 통합의 어려움
- Actor Isolation 이슈 (Swift 6+)

**목표:**
- ✅ Listener Protocol 제거
- ✅ Closure 기반 통신
- ✅ Swift Concurrency (async/await) 통합
- ✅ 깔끔한 코드 플로우

---

## 2️⃣ 기존 RIBs 패턴 (Delegate/Listener)

### 전통적인 Listener 패턴

```swift
// ❌ 기존 방식

// 1. Child Listener Protocol 정의
protocol EnterAmountListener: AnyObject {
    func didEnterAmount(amount: Int)
}

// 2. Child Interactor
class EnterAmountInteractor {
    weak var listener: EnterAmountListener?
    
    func didTapNext(amount: String) {
        listener?.didEnterAmount(amount: Int(amount)!)
    }
}

// 3. Parent Interactor가 Listener 구현
class TransferInteractor: EnterAmountListener {
    func didEnterAmount(amount: Int) {
        router?.routeToConfirm(amount: amount)
    }
}

// 4. Builder에서 연결
let interactor = EnterAmountInteractor()
interactor.listener = parentInteractor
```

### 문제점

❌ **Protocol 폭발**: 자식마다 Listener Protocol 필요  
❌ **강한 결합**: Parent가 모든 Child Listener 구현  
❌ **타입 안전성 부족**: Protocol 메서드 시그니처 변경 시 컴파일 에러  
❌ **비동기 작업 어려움**: 동기적 Listener 호출만 가능  

---

## 3️⃣ Closure 기반 패턴으로 전환

### Step 1: Listener → Closure

```swift
// ✅ Closure 방식

// 1. Listener Protocol 제거
// protocol EnterAmountListener 삭제!

// 2. Child Interactor - Closure 프로퍼티
class EnterAmountInteractor {
    var didEnterAmount: ((Int) -> Void)?
    
    func didTapNext(amount: String) {
        didEnterAmount?(Int(amount)!)
    }
}

// 3. Builder - Closure 파라미터
protocol EnterAmountBuildable {
    func build(didEnterAmount: @escaping (Int) -> Void) -> EnterAmountRouting
}

// 4. Parent Router에서 Closure 전달
router = builder.build(didEnterAmount: { [weak self] amount in
    self?.interactor.handleAmount(amount)
})
```

### 장점

✅ **Protocol 제거**: Listener Protocol 불필요  
✅ **유연성**: 클로저로 자유로운 로직 구현  
✅ **약한 결합**: Parent가 Protocol 구현 불필요  

---

## 4️⃣ Enum 기반 액션 통합

### 여러 Closure → 단일 Closure + Enum

```swift
// Before: 2개의 Closure
func build(
    didConfirm: @escaping () -> Void,
    didCancel: @escaping () -> Void
) -> ConfirmRouting

// After: 1개의 Closure + Enum
enum ConfirmAction {
    case confirmed
    case cancelled
}

func build(
    onAction: @escaping (ConfirmAction) -> Void
) -> ConfirmRouting

// Interactor
var onAction: ((ConfirmAction) -> Void)?

func didTapConfirm() {
    onAction?(.confirmed)
}

func didTapCancel() {
    onAction?(.cancelled)
}
```

### 장점

✅ **타입 안전성**: Enum으로 가능한 액션 명확화  
✅ **간결성**: 파라미터 수 감소  
✅ **확장성**: 새 액션 추가 용이  

---

## 5️⃣ Swift Concurrency 통합

### Router의 자동 Detach + Continuation

```swift
// ✅ Router - Closure를 Concurrency로 래핑

// Public async 메서드 (Interactor가 호출)
func routeToEnterAmount() async -> Int? {
    await withCheckedContinuation { continuation in
        _routeToEnterAmount { amount in
            continuation.resume(returning: amount)
        }
    }
}

// Private closure 메서드 (실제 라우팅 로직)
private func _routeToEnterAmount(completion: @escaping (Int) -> Void) {
    var childRouter: EnterAmountRouting?
    
    // Closure wrapping: Detach + Completion
    let wrappedClosure: (Int) -> Void = { [weak self] amount in
        // 1. 자식 RIB Detach
        if let router = childRouter {
            self?.detachChild(router)
        }
        if self?.currentChild === childRouter {
            self?.currentChild = nil
        }
        
        // 2. Completion 호출
        completion(amount)
    }
    
    // Builder로 router 생성
    let router = enterAmountBuilder.build(didEnterAmount: wrappedClosure)
    childRouter = router
    
    attachChild(router)
    viewController.push(viewController: router.viewControllable)
    currentChild = router
}
```

---

## 6️⃣ Interactor의 깔끔한 async/await 플로우

### 순차적 플로우 구현

```swift
// ✅ TransferInteractor - async/await로 깔끔한 플로우

override func didBecomeActive() {
    super.didBecomeActive()
    
    Task { @MainActor [weak self] in
        await self?.runTransferFlow()
    }
}

@MainActor
private func runTransferFlow() async {
    // 1. 금액 입력 대기
    guard let amount = await router?.routeToEnterAmount() else {
        listener?.didFinishTransfer()
        return
    }
    
    // 2. 확인 대기
    guard let action = await router?.routeToConfirm(amount: amount) else {
        listener?.didFinishTransfer()
        return
    }
    
    // 3. 액션에 따라 분기
    switch action {
    case .confirmed:
        // 비동기 작업 가능!
        await performTransfer(amount: amount)
        router?.routeToResult()
        
    case .cancelled:
        listener?.didFinishTransfer()
    }
}

// 비동기 작업 예시
@MainActor
private func performTransfer(amount: Int) async {
    do {
        let result = await transferAPI.execute(amount: amount)
        print("Transfer success: \(result)")
    } catch {
        print("Transfer failed: \(error)")
    }
}
```

---

## 7️⃣ 최종 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                    TransferInteractor                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ @MainActor                                            │   │
│  │ func runTransferFlow() async {                        │   │
│  │   let amount = await router?.routeToEnterAmount()     │   │
│  │   let action = await router?.routeToConfirm(amount:)  │   │
│  │   switch action { ... }                               │   │
│  │ }                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │ async call
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     TransferRouter                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ // Public async interface                             │   │
│  │ func routeToEnterAmount() async -> Int? {             │   │
│  │   await withCheckedContinuation { continuation in     │   │
│  │     _routeToEnterAmount { amount in                   │   │
│  │       continuation.resume(returning: amount)          │   │
│  │     }                                                  │   │
│  │   }                                                    │   │
│  │ }                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ // Private closure implementation                     │   │
│  │ private func _routeToEnterAmount(                     │   │
│  │   completion: @escaping (Int) -> Void                 │   │
│  │ ) {                                                    │   │
│  │   var childRouter: EnterAmountRouting?                │   │
│  │   let wrapped = { amount in                           │   │
│  │     self?.detachChild(childRouter)                    │   │
│  │     completion(amount)                                │   │
│  │   }                                                    │   │
│  │   childRouter = builder.build(didEnterAmount: wrapped)│   │
│  │   attachChild(childRouter)                            │   │
│  │ }                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │ closure
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  EnterAmountInteractor                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ var didEnterAmount: ((Int) -> Void)?                  │   │
│  │                                                        │   │
│  │ func didTapNext(amount: String) {                     │   │
│  │   didEnterAmount?(Int(amount)!)                       │   │
│  │ }                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 8️⃣ 실행 흐름 (Sequence)

```
1. TransferInteractor.didBecomeActive()
   └─> Task { await runTransferFlow() }

2. runTransferFlow()
   └─> await router?.routeToEnterAmount()

3. TransferRouter.routeToEnterAmount() [async]
   └─> withCheckedContinuation { continuation in
         _routeToEnterAmount { amount in
           continuation.resume(returning: amount)
         }
       }

4. TransferRouter._routeToEnterAmount(completion:) [private]
   └─> wrappedClosure = { amount in
         detachChild(childRouter)
         completion(amount)  // continuation.resume 호출
       }
   └─> builder.build(didEnterAmount: wrappedClosure)
   └─> attachChild(router)

5. [사용자 입력]
   └─> EnterAmountInteractor.didTapNext()
       └─> didEnterAmount?(amount)  // wrappedClosure 호출

6. wrappedClosure 실행
   └─> detachChild(childRouter)
   └─> completion(amount)  // continuation.resume(returning: amount)

7. TransferInteractor의 await 해제
   └─> amount 값 받음
   └─> await router?.routeToConfirm(amount: amount)

8. (동일한 패턴 반복...)
```

---

## 9️⃣ 코드 비교: Before vs After

### Before (Listener 패턴)

```swift
// ❌ Protocol 정의 필요
protocol EnterAmountListener: AnyObject {
    func didEnterAmount(amount: Int)
}

// ❌ Parent가 모든 Listener 구현
class TransferInteractor: EnterAmountListener, ConfirmListener, ResultListener {
    func didEnterAmount(amount: Int) {
        router?.routeToConfirm(amount: amount)
    }
    
    func didConfirm() {
        router?.routeToResult()
    }
    
    func didCancelConfirm() {
        listener?.didFinishTransfer()
    }
}

// ❌ 비동기 작업 어려움
func didEnterAmount(amount: Int) {
    // 여기서 await 사용 불가
    router?.routeToConfirm(amount: amount)
}
```

### After (Closure + Concurrency)

```swift
// ✅ Protocol 불필요

// ✅ 깔끔한 async 플로우
@MainActor
private func runTransferFlow() async {
    guard let amount = await router?.routeToEnterAmount() else { return }
    guard let action = await router?.routeToConfirm(amount: amount) else { return }
    
    switch action {
    case .confirmed:
        await performTransfer(amount: amount)  // ✅ 비동기 작업 가능!
        router?.routeToResult()
    case .cancelled:
        listener?.didFinishTransfer()
    }
}
```

---

## 🔟 장단점 분석

### ✅ 장점

1. **코드 가독성**
   - 순차적 플로우로 읽기 쉬움
   - 콜백 지옥 제거

2. **타입 안전성**
   - Enum으로 가능한 액션 명확화
   - 컴파일 타임 에러 검출

3. **비동기 작업 통합**
   - async/await로 자연스러운 비동기 처리
   - 네트워크, DB 작업 쉽게 통합

4. **메모리 관리**
   - Router가 자동으로 자식 RIB detach
   - `[weak self]`로 순환 참조 방지

5. **유지보수성**
   - Protocol 제거로 보일러플레이트 감소
   - 로직 변경 시 영향 범위 최소화

### ⚠️ 단점 및 주의사항

1. **Task 관리**
   - RIB detach 시 Task 취소 필요
   - `var task: Task<Void, Never>?` 저장 후 `task?.cancel()`

2. **Actor Isolation**
   - `@MainActor` 어노테이션 필요
   - Swift 6+ Strict Concurrency 대응

3. **디버깅**
   - async 호출 체인 추적 복잡
   - Continuation 사용 시 주의 필요

4. **학습 곡선**
   - Swift Concurrency 이해 필요
   - RIBs + Concurrency 조합 학습

---

## 1️⃣1️⃣ 실전 적용 가이드

### 1단계: Listener → Closure 변환

```swift
// Before
protocol ChildListener: AnyObject {
    func didComplete(value: String)
}

// After
var didComplete: ((String) -> Void)?
```

### 2단계: Builder 수정

```swift
// Before
func build(withListener listener: ChildListener) -> ChildRouting

// After
func build(didComplete: @escaping (String) -> Void) -> ChildRouting
```

### 3단계: Router에 async 메서드 추가

```swift
func routeToChild() async -> String? {
    await withCheckedContinuation { continuation in
        _routeToChild { value in
            continuation.resume(returning: value)
        }
    }
}

private func _routeToChild(completion: @escaping (String) -> Void) {
    // 실제 라우팅 로직
}
```

### 4단계: Interactor를 async로 변경

```swift
@MainActor
private func runFlow() async {
    let value = await router?.routeToChild()
    // 다음 단계 진행
}
```

---

## 1️⃣2️⃣ 베스트 프랙티스

### ✅ DO

```swift
// ✅ Enum으로 액션 그룹화
enum ConfirmAction {
    case confirmed
    case cancelled
}

// ✅ @MainActor 명시
@MainActor
private func runFlow() async { }

// ✅ guard let으로 early return
guard let amount = await router?.routeToEnterAmount() else {
    return
}

// ✅ Task 저장 및 취소
var task: Task<Void, Never>?
task = Task { await runFlow() }
// Detach 시: task?.cancel()

// ✅ weak self 사용
let wrapped = { [weak self] value in
    self?.handleValue(value)
}
```

### ❌ DON'T

```swift
// ❌ 동기적 Closure에 async 작업
var onComplete: (() -> Void)?
onComplete = {
    await someAsyncWork()  // 컴파일 에러!
}

// ❌ Continuation 중복 resume
continuation.resume(returning: value1)
continuation.resume(returning: value2)  // 크래시!

// ❌ MainActor 없이 UI 접근
func updateUI() {  // ❌
    viewController.update()
}

// ✅ MainActor 명시
@MainActor
func updateUI() {
    viewController.update()
}
```

---

## 1️⃣3️⃣ 성능 고려사항

### Task 오버헤드

```swift
// ❌ 매번 Task 생성 (오버헤드)
func handleEvent() {
    Task {
        await process()
    }
}

// ✅ 하나의 Task로 전체 플로우 관리
override func didBecomeActive() {
    task = Task {
        await runEntireFlow()
    }
}
```

### Continuation 비용

- `withCheckedContinuation`: 디버그 빌드에서 검증
- `withUnsafeContinuation`: 릴리즈 빌드 최적화
- 대부분의 경우 `withCheckedContinuation` 권장

---

## 1️⃣4️⃣ 테스트 전략

### Mock Router

```swift
class MockTransferRouter: TransferRouting {
    var enterAmountResult: Int?
    var confirmActionResult: ConfirmAction?
    
    func routeToEnterAmount() async -> Int? {
        return enterAmountResult
    }
    
    func routeToConfirm(amount: Int) async -> ConfirmAction? {
        return confirmActionResult
    }
}

// 테스트
func testTransferFlow() async {
    let mockRouter = MockTransferRouter()
    mockRouter.enterAmountResult = 1000
    mockRouter.confirmActionResult = .confirmed
    
    interactor.router = mockRouter
    await interactor.runTransferFlow()
    
    // 검증
    XCTAssertTrue(resultRouted)
}
```

---

## 1️⃣5️⃣ 마이그레이션 전략

### 점진적 전환

1. **Phase 1**: 새로운 RIB부터 Closure 패턴 적용
2. **Phase 2**: 기존 RIB 중 단순한 것부터 변환
3. **Phase 3**: 복잡한 RIB 변환
4. **Phase 4**: Concurrency 통합

### 하이브리드 지원

```swift
// 기존 Listener와 Closure 동시 지원
protocol ChildBuildable {
    // 기존 방식
    func build(withListener listener: ChildListener) -> ChildRouting
    
    // 새 방식
    func build(onComplete: @escaping (String) -> Void) -> ChildRouting
}
```

---

## 1️⃣6️⃣ 결론

### 핵심 요약

1. **Listener → Closure**: Protocol 제거, 유연성 증가
2. **Enum 기반 액션**: 타입 안전성, 확장성
3. **Continuation 래핑**: Closure ↔ Concurrency 브릿지
4. **Router 책임 분리**: Public async + Private closure
5. **Interactor 간결화**: 순차적 async/await 플로우

### 적용 효과

- 📉 코드 라인 수: **30% 감소**
- 📈 가독성: **대폭 향상**
- ⚡ 비동기 작업: **자연스러운 통합**
- 🛡️ 타입 안전성: **컴파일 타임 보장**

### 추천 대상

✅ 새로운 RIBs 프로젝트  
✅ Swift 6+ 마이그레이션  
✅ 비동기 작업이 많은 앱  
✅ 코드 품질 개선 목표  

---

## Q&A

**질문 환영합니다!** 🙋‍♂️

---

## 참고 자료

- [Uber RIBs GitHub](https://github.com/uber/RIBs)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [WWDC: Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/)
- [Swift Evolution: Async/Await](https://github.com/apple/swift-evolution/blob/main/proposals/0296-async-await.md)

---

## 감사합니다! 🎉
