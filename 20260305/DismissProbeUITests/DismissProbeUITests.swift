import XCTest

private struct LifecycleEvent: Decodable {
    let timestamp: String
    let vcName: String
    let event: String
    let isBeingDismissed: Bool
    let isMovingFromParent: Bool
    let viewWindowIsNil: Bool
    let hasPresentingVC: Bool
    let hasNavigationController: Bool
}

final class DismissProbeUITests: XCTestCase {
    private let app = XCUIApplication()
    private let logPath = NSTemporaryDirectory()
        .appending("dismiss-probe-events-\(UUID().uuidString).jsonl")
    private let rootButtonTimeout: TimeInterval = 3

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        if FileManager.default.fileExists(atPath: logPath) {
            try? FileManager.default.removeItem(atPath: logPath)
        }

        app.launchEnvironment["DISMISS_UI_TEST_LOG_PATH"] = logPath
        print("🚀 launch log path: \(logPath)")
        app.launch()
        waitScenarioButtonHittable(1)
    }

    override func tearDown() {
        if FileManager.default.fileExists(atPath: logPath) {
            if let data = FileManager.default.contents(atPath: logPath),
               let text = String(data: data, encoding: .utf8) {
                print("📄 event log snapshot (\(text.split(whereSeparator: \.isNewline).count) lines):")
                print(text)
            } else {
                print("⚠️ 이벤트 로그 파일을 읽을 수 없습니다: \(logPath)")
            }
        } else {
            print("⚠️ 이벤트 로그 파일 없음: \(logPath)")
        }
        app.terminate()
        super.tearDown()
    }

    func testScenario1_CodeDismiss() throws {
        tapScenarioButton(1)

        let child = app.otherElements["Scenario1ChildViewController-view"]
        XCTAssertTrue(child.waitForExistence(timeout: 2))
        app.buttons["Scenario1ChildViewController-action"].tap()

        XCTAssertTrue(app.buttons["scenario-1-button"].waitForExistence(timeout: 2))
        let event = try waitEvent(vcName: "Scenario1ChildViewController")

        XCTAssertTrue(event.isBeingDismissed)
        XCTAssertFalse(event.isMovingFromParent)
        XCTAssertTrue(event.viewWindowIsNil)
    }

    func testScenario2_SwipeDismiss() throws {
        tapScenarioButton(2)

        let child = app.otherElements["Scenario2ChildViewController-view"]
        XCTAssertTrue(child.waitForExistence(timeout: 2))
        swipeDownCardForDismiss(child)

        XCTAssertTrue(waitForElementToDisappear(child, timeout: 4))
        waitScenarioButtonHittable(2)
        let event = try waitEvent(vcName: "Scenario2ChildViewController")

        XCTAssertTrue(event.isBeingDismissed)
        XCTAssertFalse(event.isMovingFromParent)
        XCTAssertTrue(event.viewWindowIsNil)
    }

    func testScenario3_SwipeCancel_NoDisappear() {
        tapScenarioButton(3)

        let child = app.otherElements["Scenario3ChildViewController-view"]
        XCTAssertTrue(child.waitForExistence(timeout: 2))

        let before = disappearEventsCount(for: "Scenario3ChildViewController")
        swipeDownCardForCancel(child)

        usleep(500_000)
        XCTAssertEqual(disappearEventsCount(for: "Scenario3ChildViewController"), before)

        swipeDownCardForDismiss(child)
        XCTAssertTrue(waitForElementToDisappear(child, timeout: 4))
        waitScenarioButtonHittable(3)
        XCTAssertGreaterThan(disappearEventsCount(for: "Scenario3ChildViewController"), before)
    }

    func testScenario4_NavigationPop() throws {
        tapScenarioButton(4)

        XCTAssertTrue(app.buttons["Scenario4ChildViewController-action"].waitForExistence(timeout: 2))
        app.buttons["Scenario4ChildViewController-action"].tap()

        waitScenarioButtonHittable(4)
        let event = try waitEvent(vcName: "Scenario4ChildViewController")

        XCTAssertFalse(event.isBeingDismissed)
        XCTAssertTrue(event.isMovingFromParent)
        XCTAssertTrue(event.viewWindowIsNil)
    }

    func testScenario5_NavControllerDismiss() throws {
        tapScenarioButton(5)

        let action = app.buttons["Scenario5CViewController-action"]
        XCTAssertTrue(action.waitForExistence(timeout: 2))
        action.tap()

        waitScenarioButtonHittable(5, timeout: 4)

        let events = lastEventsByVC()
        let c = events["Scenario5CViewController"]

        XCTAssertNotNil(c)
        if let c {
            XCTAssertFalse(c.isBeingDismissed)
            XCTAssertFalse(c.isMovingFromParent)
            XCTAssertTrue(c.viewWindowIsNil)
        }
        XCTAssertNil(events["Scenario5AViewController"], "A/B are not expected to receive viewDidDisappear during parent dismiss in current runtime.")
        XCTAssertNil(events["Scenario5BViewController"], "A/B are not expected to receive viewDidDisappear during parent dismiss in current runtime.")
    }

    func testScenario5_SwipeDismissCancel_NoDisappear() {
        tapScenarioButton(5)

        let childC = app.otherElements["Scenario5CViewController-view"]
        XCTAssertTrue(childC.waitForExistence(timeout: 2))

        let before = disappearEventsCount(for: "Scenario5CViewController")
        swipeDownCardForCancel(childC)
        usleep(500_000)

        XCTAssertEqual(disappearEventsCount(for: "Scenario5CViewController"), before)
        XCTAssertTrue(childC.exists)
        XCTAssertFalse(app.buttons["scenario-5-button"].exists)

        let action = app.buttons["Scenario5CViewController-action"]
        XCTAssertTrue(action.waitForExistence(timeout: 2))
        action.tap()

        waitForElementToDisappear(childC, timeout: 4)
        waitScenarioButtonHittable(5, timeout: 4)
    }

    func testScenario6_PopToRoot() throws {
        tapScenarioButton(6)

        let action = app.buttons["Scenario6CViewController-action"]
        XCTAssertTrue(action.waitForExistence(timeout: 2))
        action.tap()

        waitScenarioButtonHittable(6, timeout: 4)

        let events = lastEventsByVC()
        let c = events["Scenario6CViewController"]

        XCTAssertNotNil(c)
        if let c {
            XCTAssertFalse(c.isBeingDismissed)
            XCTAssertTrue(c.isMovingFromParent)
            XCTAssertTrue(c.viewWindowIsNil)
        }
        XCTAssertNil(events["Scenario6AViewController"], "A/B are not expected to receive viewDidDisappear during popToRoot in current runtime.")
        XCTAssertNil(events["Scenario6BViewController"], "A/B are not expected to receive viewDidDisappear during popToRoot in current runtime.")
    }

    func testScenario7_PresentOverlay_NoDismissSignal() {
        tapScenarioButton(7)

        let child = app.otherElements["Scenario7ChildViewController-view"]
        XCTAssertTrue(child.waitForExistence(timeout: 2))

        let before = readEvents().filter { $0.event == "viewDidDisappear" }.count

        app.buttons["Scenario7ChildViewController-action"].tap()

        let overlayButton = app.buttons["Scenario7OverlayViewController-action"]
        XCTAssertTrue(overlayButton.waitForExistence(timeout: 2))
        XCTAssertEqual(readEvents().filter { $0.event == "viewDidDisappear" }.count, before)

        overlayButton.tap()
        XCTAssertTrue(child.waitForExistence(timeout: 2))

        if app.buttons["scenario-7-back-button"].exists {
            app.buttons["scenario-7-back-button"].tap()
        } else {
            app.navigationBars["Scenario7ChildViewController"].buttons.element(boundBy: 0).tap()
        }
        waitScenarioButtonHittable(7)
    }

    func testScenario8_FullScreenPullScreen() throws {
        tapScenarioButton(8)

        let root = app.otherElements["Scenario8PullScreenViewController-view"]
        XCTAssertTrue(root.waitForExistence(timeout: 2))

        app.buttons["Scenario8PullScreenViewController-action"].tap()
        let detail = app.otherElements["Scenario8PullScreenDetailViewController-view"]
        XCTAssertTrue(detail.waitForExistence(timeout: 2))

        app.navigationBars["Scenario8PullScreenDetailViewController"].buttons.element(boundBy: 0).tap()
        XCTAssertTrue(root.waitForExistence(timeout: 2))
        let detailEvent = try waitEvent(vcName: "Scenario8PullScreenDetailViewController")

        XCTAssertTrue(detailEvent.isMovingFromParent)
        XCTAssertTrue(detailEvent.viewWindowIsNil)

        app.buttons["scenario8-pullscreen-close"].tap()
        XCTAssertTrue(waitForElementToDisappear(root, timeout: 5))

        let rootEvent = try waitEvent(vcName: "Scenario8PullScreenViewController")
        XCTAssertTrue(rootEvent.viewWindowIsNil)
    }

    private func tapScenarioButton(_ index: Int) {
        app.buttons["scenario-\(index)-button"].tap()
    }

    private func waitScenarioButtonHittable(_ index: Int, timeout: TimeInterval = 3) {
        let button = app.buttons["scenario-\(index)-button"]
        let predicate = NSPredicate(format: "exists == YES AND isHittable == YES")
        let expectation = expectation(for: predicate, evaluatedWith: button, handler: nil)
        wait(for: [expectation], timeout: timeout)
    }

    private func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !element.exists {
                return true
            }
            usleep(100_000)
        }
        return false
    }

    private func swipeDownCardForDismiss(_ element: XCUIElement) {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.86))
        start.press(forDuration: 0.15, thenDragTo: end)
    }

    private func swipeDownCardForCancel(_ element: XCUIElement) {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.34))
        let end = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.44))
        start.press(forDuration: 0.15, thenDragTo: end)
    }

    private func waitEvent(vcName: String, timeout: TimeInterval = 5) throws -> LifecycleEvent {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if let event = readEvents().last(where: { $0.vcName == vcName && $0.event == "viewDidDisappear" }) {
                return event
            }
            usleep(100_000)
        }

        XCTFail("\(vcName) event not found")
        struct EventNotFound: Error {}
        throw EventNotFound()
    }

    private func lastEventsByVC() -> [String: LifecycleEvent] {
        let events = readEvents().filter { $0.event == "viewDidDisappear" }
        var latest: [String: LifecycleEvent] = [:]
        for event in events {
            latest[event.vcName] = event
        }
        return latest
    }

    private func disappearEventsCount(for vcName: String) -> Int {
        readEvents().filter { $0.vcName == vcName && $0.event == "viewDidDisappear" }.count
    }

    private func readEvents() -> [LifecycleEvent] {
        guard let data = FileManager.default.contents(atPath: logPath),
              let text = String(data: data, encoding: .utf8) else {
            return []
        }

        return text
            .split(whereSeparator: { $0.isNewline })
            .compactMap { line -> LifecycleEvent? in
                guard !line.isEmpty,
                      let data = line.data(using: .utf8) else { return nil }
                return try? JSONDecoder().decode(LifecycleEvent.self, from: data)
            }
    }
}
