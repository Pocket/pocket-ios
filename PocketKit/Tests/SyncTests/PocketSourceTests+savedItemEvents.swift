// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Sync

// swiftlint:disable force_try
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
        wait(for: [receivedNotification], timeout: 2)
    }

    func test_events_whenOSNotificationCenterPostsSavedItemUpdatedNotification_publishesAnEvent_andDeletesNotificationRecords() {
        let source = subject()

        let savedItem = try! space.createSavedItem()
        let receivedNotification = expectation(description: "received notification")
        source.events.sink { event in
            guard case .savedItemsUpdated(let savedItems) = event else {
                XCTFail("Received unexpected sync event: \(event)")
                return
            }

            XCTAssertEqual(savedItems, [savedItem])
            receivedNotification.fulfill()
        }.store(in: &subscriptions)

        let notification: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
        notification.savedItem = savedItem
        try! space.save()

        osNotificationCenter.post(name: .savedItemUpdated)
        wait(for: [receivedNotification], timeout: 2)

        let notifications = try? space.fetchSavedItemUpdatedNotifications()
        XCTAssertEqual(notifications, [])
        XCTAssertFalse(space.backgroundContext.hasChanges)
    }

    func test_events_whenOSNotificationCenterPostsUnresolvedItemCreatedNotification_enqueuesASaveItemOperation() throws {
        let operationStarted = expectation(description: "operationStarted")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                operationStarted.fulfill()
            }
        }

        var source: PocketSource? = subject()

        let savedItem = try! space.createSavedItem()
        let unresolved: UnresolvedSavedItem = UnresolvedSavedItem(context: space.backgroundContext)
        unresolved.savedItem = savedItem
        try space.save()

        osNotificationCenter.post(name: .unresolvedSavedItemCreated)

        wait(for: [operationStarted], timeout: 2)

        try XCTAssertEqual(space.fetchUnresolvedSavedItems(), [])

        source = nil
    }

    func test_events_whenOSNotificationCenterPostsUnresolvedItemCreatedNotification_whenSavedItemIsDuplicated_includesSavedItemOnlyOnce() throws {
        operations.stubSaveItemOperation { _, _, _, _, _ in
            TestSyncOperation { }
        }

        let source = subject()

        let savedItem = try! space.createSavedItem()
        let notification1: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
        notification1.savedItem = savedItem
        try! space.save()

        let notification2: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
        notification2.savedItem = savedItem
        try space.save()

        let expectEvent = expectation(description: "expectEvent")
        let sub = source.events.sink { event in
            guard case .savedItemsUpdated(let savedItems) = event else {
                XCTFail("Received unexpected sync event: \(event)")
                return
            }

            XCTAssertEqual(Array(savedItems), [savedItem])
            expectEvent.fulfill()
        }

        osNotificationCenter.post(name: .savedItemUpdated)

        wait(for: [expectEvent], timeout: 2)
        sub.cancel()
    }
}
// swiftlint:enable force_try
