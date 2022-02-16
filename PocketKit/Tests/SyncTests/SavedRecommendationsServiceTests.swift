import XCTest
import CoreData
import Combine

@testable import Sync


class SavedRecommendationServiceTests: XCTestCase {
    var space: Space!
    var subscriptions: [AnyCancellable]!

    override func setUpWithError() throws {
        space = Space(container: .testContainer)
        subscriptions = []

        try space.seedSavedItem(
            remoteID: "saved-item-1",
            url: "http://example.com/item-1",
            item: space.buildItem(
                remoteID: "item-1",
                title: "Item 1"
            )
        )

        try space.seedSavedItem(
            remoteID: "saved-item-2",
            url: "http://example.com/item-2",
            item: space.buildItem(
                remoteID: "item-2",
                title: "Item 2"
            )
        )

        try space.seedSavedItem(
            remoteID: "saved-item-3",
            url: "http://example.com/item-3",
            isArchived: true,
            item: space.buildItem(
                remoteID: "item-3",
                title: "Archived Item"
            )
        )
    }

    override func tearDownWithError() throws {
        try space.clear()
    }

    func subject(space: Space? = nil) -> SavedRecommendationsService {
        return SavedRecommendationsService(space: space ?? self.space)
    }

    func test_settingSlates_notifiesObserversWithTheIDsOfItemsThatHaveBeenSaved() throws {
        let service = subject()

        var savedItemIDs: [String] = []
        service.$itemIDs.sink { itemIDs in
            savedItemIDs = itemIDs
        }.store(in: &subscriptions)

        service.slates = [
            .build(
                recommendations: [
                    .build(item: .build(id: "item-1")),
                    .build(item: .build(id: "item-not-saved"))
                ]
            ),
            .build(
                recommendations: [
                    .build(item: .build(id: "item-3")),
                    .build(item: .build(id: "item-4"))
                ]
            )
        ]

        XCTAssertEqual(service.itemIDs, ["item-1"])
        XCTAssertEqual(savedItemIDs, ["item-1"])
    }

    func test_savingAnItemToLocalStorage_notifiesObserversWithTheIDsOfItemsThatHaveBeenSaved() throws {
        let service = subject()

        service.slates = [
            .build(
                recommendations: [
                    .build(item: .build(id: "item-1")),
                    .build(item: .build(id: "item-not-saved"))
                ]
            ),
            .build(
                recommendations: [
                    .build(item: .build(id: "item-3")),
                    .build(item: .build(id: "item-4"))
                ]
            )
        ]

        var updateCount = 0
        let expectationToUpdateItemIDs = expectation(description: "update item ids")
        service.$itemIDs.sink { itemIDs in
            // This callback will fire immediately when subscribing
            // We don't want to fulfill the expectation
            // until saving a new item triggers the observer again
            updateCount += 1
            if updateCount == 2 {
                expectationToUpdateItemIDs.fulfill()
            }
        }.store(in: &subscriptions)

        try space.seedSavedItem(
            remoteID: "saved-item-4",
            item: space.buildItem(
                remoteID: "item-4",
                title: "Item 4"
            )
        )

        wait(for: [expectationToUpdateItemIDs], timeout: 1)
        XCTAssertEqual(service.itemIDs, ["item-1", "item-4"])
    }
}
