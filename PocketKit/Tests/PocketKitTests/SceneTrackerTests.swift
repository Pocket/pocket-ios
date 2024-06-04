// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Analytics
@testable import PocketKit

class SceneTrackerTests: XCTestCase {
    var userDefaults: UserDefaults!
    var notificationCenter: NotificationCenter!
    var tracker: MockTracker!
    var sceneTracker: SceneTracker!

    @MainActor
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults()
        notificationCenter = NotificationCenter()
        tracker = MockTracker()
        sceneTracker = SceneTracker(
            tracker: tracker,
            userDefaults: userDefaults,
            notificationCenter: notificationCenter
        )
    }

    @MainActor
    override func tearDown() {
        userDefaults.removeObject(forKey: SceneTracker.dateLastOpenedKey)
        userDefaults.removeObject(forKey: SceneTracker.dateLastBackgroundedKey)
        super.tearDown()
    }

    // MARK: - AppOpen

    func test_trackAppOpenWithNoPreviousOpenOrBackground() {
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)

        XCTAssertTrue(tracker.oldTrackCalls.wasCalled)

        let event = tracker.oldTrackCalls.last?.event as? AppOpenEvent
        XCTAssertNotNil(event)

        XCTAssertNil(event!.secondsSinceLastOpen)
        XCTAssertNil(event!.secondsSinceLastBackground)
    }

    func test_doesNotTrackSecondAppOpenIfCurrentlyActive() {
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)

        XCTAssertEqual(tracker.oldTrackCalls.count, 1)
    }

    func test_trackAppOpenAfterPreviousOpenAndBackground() {
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)
        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: nil)
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)

        let event = tracker.oldTrackCalls.last?.event as? AppOpenEvent
        XCTAssertNotNil(event)
        XCTAssertNotNil(event!.secondsSinceLastOpen)
        XCTAssertNotNil(event!.secondsSinceLastBackground)
    }

    // MARK: - AppBackground

    func test_trackAppBackgroundAfterOpenButNoPreviousBackground() {
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)
        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: nil)

        let event = tracker.oldTrackCalls.last?.event as? AppBackgroundEvent
        XCTAssertNotNil(event)
        XCTAssertNotNil(event!.secondsSinceLastOpen)
        XCTAssertNil(event!.secondsSinceLastBackground)
    }

    func test_trackAppBackgroundAfterPreviousOpenAndBackground() {
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)
        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: nil)
        notificationCenter.post(name: UIScene.didActivateNotification, object: nil)
        notificationCenter.post(name: UIScene.didEnterBackgroundNotification, object: nil)

        let event = tracker.oldTrackCalls.last?.event as? AppBackgroundEvent
        XCTAssertNotNil(event)
        XCTAssertNotNil(event!.secondsSinceLastOpen)
        XCTAssertNotNil(event!.secondsSinceLastBackground)
    }
}
