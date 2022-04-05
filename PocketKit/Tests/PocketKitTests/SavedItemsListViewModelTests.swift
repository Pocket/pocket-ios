import XCTest
import Analytics
import Sync
import Combine
@testable import PocketKit


class SavedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var itemsController: MockSavedItemsController!
    var subscriptions: [AnyCancellable]!

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        subscriptions = []
        itemsController = MockSavedItemsController()

        itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeItemsController { self.itemsController }
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> SavedItemsListViewModel {
        SavedItemsListViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_shouldSelectCell_whenItemIsPending_returnsFalse() {
        let viewModel = subject()

        let item = SavedItem.build(item: nil)

        source.stubObject { _ in
            item
        }

        XCTAssertFalse(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_shouldSelectCell_whenItemIsNotPending_returnsFalse() {
        let viewModel = subject()

        let item = SavedItem.build()

        source.stubObject { _ in item }

        XCTAssertTrue(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_sourceEvents_whenEventIsSavedItemCreated_sendsSnapshotWithNewItem() {
        let savedItem: SavedItem = .build()
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = [savedItem]
        }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            let itemIDs = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(itemIDs, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemCreated)

        wait(for: [snapshotSent], timeout: 1)
    }

    func test_sourceEvents_whenEventIsSavedItemUpdated_sendsSnapshotWithUpdatedItem() {
        let savedItem: SavedItem = .build()
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = [savedItem]
        }
        source.stubRefreshObject { _, _ in }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            XCTAssertEqual(self.source.refreshObjectCall(at: 0)?.object, savedItem)
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemsUpdated([savedItem]))

        wait(for: [snapshotSent], timeout: 1)
    }
}
