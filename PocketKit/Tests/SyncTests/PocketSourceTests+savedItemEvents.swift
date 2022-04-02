import XCTest
@testable import Sync


extension PocketSourceTests {
    func test_events_whenOSNotificationCenterPostsSavedItemCreatedNotification_publishesAnEvent() {
        let source = subject()

        let receivedNotification = expectation(description: "received notification")
        source.events.sink { event in
            guard case .savedItemCreated = event else {
                XCTFail("Received unexpected sync event: \(event)")
                return
            }

            receivedNotification.fulfill()
        }.store(in: &subscriptions)

        osNotificationCenter.post(name: .savedItemCreated)
        wait(for: [receivedNotification], timeout: 1)
    }

    func test_events_whenOSNotificationCenterPostsSavedItemUpdatedNotification_publishesAnEvent_andDeletesNotificationRecords() {
        let source = subject()

        let savedItem = try! space.seedSavedItem()
        let receivedNotification = expectation(description: "received notification")
        source.events.sink { event in
            guard case .savedItemsUpdated(let savedItems) = event else {
                XCTFail("Received unexpected sync event: \(event)")
                return
            }

            XCTAssertEqual(savedItems, [savedItem])
            receivedNotification.fulfill()
        }.store(in: &subscriptions)

        let notification: SavedItemUpdatedNotification = space.new()
        notification.savedItem = savedItem
        try! space.save()

        osNotificationCenter.post(name: .savedItemUpdated)
        wait(for: [receivedNotification], timeout: 1)

        let notifications = try? space.fetchSavedItemUpdatedNotifications()
        XCTAssertEqual(notifications, [])
        XCTAssertFalse(space.context.hasChanges)
    }
}
