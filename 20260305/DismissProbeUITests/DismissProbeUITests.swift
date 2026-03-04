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
    private let logPath = NSTemporaryDirectory().appending("dismiss-probe-events.jsonl")
    private let rootButtonTimeout: TimeInterval = 3

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        if FileManager.default.fileExists(atPath: logPath) {
            try? FileManager.default.removeItem(atPath: logPath)
        }

        app.launchEnvironment["DISMISS_UI_TEST_LOG_PATH"] = logPath
        app.launch()
        XCTAssertTrue(app.buttons["scenario-1-button"].waitForExistence(timeout: rootButtonTimeout))
    }

    override func tearDown() {
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
        child.swipeDown()

        XCTAssertTrue(app.buttons["scenario-2-button"].waitForExistence(timeout: 3))
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
        let start = child.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.28))
        let end = child.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.40))
        start.press(forDuration: 0.15, thenDragTo: end)

        usleep(500_000)
        XCTAssertEqual(disappearEventsCount(for: "Scenario3ChildViewController"), before)

        child.swipeDown()
        XCTAssertTrue(app.buttons["scenario-3-button"].waitForExistence(timeout: 3))
        XCTAssertGreaterThan(disappearEventsCount(for: "Scenario3ChildViewController"), before)
    }

    func testScenario4_NavigationPop() throws {
        tapScenarioButton(4)

        XCTAssertTrue(app.buttons["Scenario4ChildViewController-action"].waitForExistence(timeout: 2))
        app.buttons["Scenario4ChildViewController-action"].tap()

        XCTAssertTrue(app.buttons["scenario-4-button"].waitForExistence(timeout: 2))
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

        XCTAssertTrue(app.buttons["scenario-5-button"].waitForExistence(timeout: 3))

        let events = lastEventsByVC()
        let a = events["Scenario5AViewController"]
        let b = events["Scenario5BViewController"]
        let c = events["Scenario5CViewController"]

        XCTAssertNotNil(a)
        XCTAssertNotNil(b)
        XCTAssertNotNil(c)

        if let a {
            XCTAssertFalse(a.isBeingDismissed)
            XCTAssertFalse(a.isMovingFromParent)
            XCTAssertTrue(a.viewWindowIsNil)
        }
        if let b {
            XCTAssertFalse(b.isBeingDismissed)
            XCTAssertFalse(b.isMovingFromParent)
            XCTAssertTrue(b.viewWindowIsNil)
        }
        if let c {
            XCTAssertFalse(c.isBeingDismissed)
            XCTAssertFalse(c.isMovingFromParent)
            XCTAssertTrue(c.viewWindowIsNil)
        }
    }

    func testScenario6_PopToRoot() throws {
        tapScenarioButton(6)

        let action = app.buttons["Scenario6CViewController-action"]
        XCTAssertTrue(action.waitForExistence(timeout: 2))
        action.tap()

        XCTAssertTrue(app.buttons["scenario-6-button"].waitForExistence(timeout: 3))

        let events = lastEventsByVC()
        let a = events["Scenario6AViewController"]
        let b = events["Scenario6BViewController"]
        let c = events["Scenario6CViewController"]

        XCTAssertNotNil(a)
        XCTAssertNotNil(b)
        XCTAssertNotNil(c)

        if let a {
            XCTAssertFalse(a.isBeingDismissed)
            XCTAssertFalse(a.isMovingFromParent)
            XCTAssertTrue(a.viewWindowIsNil)
        }
        if let b {
            XCTAssertFalse(b.isBeingDismissed)
            XCTAssertFalse(b.isMovingFromParent)
            XCTAssertTrue(b.viewWindowIsNil)
        }
        if let c {
            XCTAssertFalse(c.isBeingDismissed)
            XCTAssertTrue(c.isMovingFromParent)
            XCTAssertTrue(c.viewWindowIsNil)
        }
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
        XCTAssertTrue(app.buttons["scenario-7-button"].waitForExistence(timeout: 2))
    }

    private func tapScenarioButton(_ index: Int) {
        app.buttons["scenario-\(index)-button"].tap()
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
