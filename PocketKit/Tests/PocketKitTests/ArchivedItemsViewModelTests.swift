import XCTest
import Sync
import Combine
import Network
import Analytics

@testable import PocketKit

enum FakeError: Error {
    case error
}

class ArchivedItemsViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var networkMonitor: MockNetworkPathMonitor!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
        self.tracker = MockTracker()
        self.networkMonitor = MockNetworkPathMonitor()
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        networkMonitor: NetworkPathMonitor? = nil
    ) -> ArchivedItemsListViewModel {
        ArchivedItemsListViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            networkMonitor: networkMonitor ?? self.networkMonitor
        )
    }

    func test_fetch_returnsArchivedItemsFromSource() {
        let archivedItems = [
            ArchivedItem.build(remoteID: "1"),
            ArchivedItem.build(remoteID: "2")
        ]

        source.stubFetchArchivedItems {
            return archivedItems
        }

        let viewModel = subject()

        let expectEmptySnapshot = expectation(description: "expect empty snapshot")
        let expectInitialSnapshot = expectation(description: "expect initial snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            if snapshot.itemIdentifiers(inSection: .items).isEmpty {
                expectEmptySnapshot.fulfill()
                return
            }

            if snapshot.itemIdentifiers(inSection: .items).count == 2 {
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item("1"), .item("2")])
                expectInitialSnapshot.fulfill()
                return
            }
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [expectEmptySnapshot, expectInitialSnapshot], timeout: 1)

        XCTAssertEqual(
            viewModel.item(with: "1")?.attributedTitle.string,
            "http://example.com"
        )
    }

    func test_deleteAction_delegatesToSource_andUpdatesSnapshot() {
        source.stubDelete { _ in }
        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1"), ArchivedItem.build(remoteID: "2")]
        }

        let viewModel = subject()
        awaitInitialSnapshot(viewModel)

        let expectSnapshotWithItemRemoved = expectation(description: "expected deleted item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item("2")])
            expectSnapshotWithItemRemoved.fulfill()
        }.store(in: &subscriptions)

        // Tap delete button in overflow menu
        viewModel.overflowActions(for: "1")?
            .first { $0.title == "Delete" }?
            .handler?(nil)

        // Tap "Yes" on confirmation alert
        viewModel.presentedAlert?
            .actions
            .first { $0.title == "Yes" }?.invoke()


        wait(for: [expectSnapshotWithItemRemoved], timeout: 1)

        let predicate = NSPredicate { _, _ in self.source.deleteArchivedItemCall(at: 0) != nil }
        wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: 2)
    }

    func test_deleteAction_whenOperationFails_addsArchivedItemBackIntoSnapshot() {
        source.stubDelete { _ in
            throw FakeError.error
        }

        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1"), ArchivedItem.build(remoteID: "2")]
        }

        let viewModel = subject()
        awaitInitialSnapshot(viewModel)

        let expectSnapshotWithItemRemoved = expectation(description: "expected deleted item snapshot")
        let expectSnapshotWithItemReadded = expectation(description: "expected readded item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            let itemIdentifiers = snapshot.itemIdentifiers(inSection: .items)

            if itemIdentifiers.count == 1 {
                expectSnapshotWithItemRemoved.fulfill()
                return
            }

            if itemIdentifiers.count == 2 {
                XCTAssertEqual(itemIdentifiers, [.item("1"), .item("2")])
                expectSnapshotWithItemReadded.fulfill()
                return
            }

            XCTFail("Received unexepected snapshot event: \(snapshot)")
        }.store(in: &subscriptions)

        // Tap delete button in overflow menu
        viewModel.overflowActions(for: "1")?
            .first { $0.title == "Delete" }?
            .handler?(nil)

        // Tap "Yes" on confirmation alert
        viewModel.presentedAlert?
            .actions
            .first { $0.title == "Yes" }?.invoke()

        wait(for: [expectSnapshotWithItemRemoved, expectSnapshotWithItemReadded], timeout: 1)
        XCTAssertNotNil(viewModel.presentedAlert)

        viewModel.presentedAlert?.actions.first?.invoke()
        XCTAssertNil(viewModel.presentedAlert)
    }

    func tests_favoriteAction_delegatesToSource_andUpdatesSnapshot() throws {
        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1"), ArchivedItem.build(remoteID: "2")]
        }

        source.stubFavoriteArchivedItem { _ in

        }

        let viewModel = subject()
        awaitInitialSnapshot(viewModel)

        let expectSnapshotWithReloadedItem = expectation(description: "expected reloaded item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item("1"), .item("2")]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                [.item("1")]
            )

            expectSnapshotWithReloadedItem.fulfill()
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: "1")?.handler?(nil)

        let predicate = NSPredicate { _, _ in self.source.favoriteArchivedItemCall(at: 0) != nil }
        wait(for: [
            expectSnapshotWithReloadedItem,
            expectation(for: predicate, evaluatedWith: nil)
        ], timeout: 2, enforceOrder: true)

        XCTAssertEqual(viewModel.favoriteAction(for: "1")?.title, "Unfavorite")
    }

    func tests_favoriteAction_whenOperationFails_marksItemAsUnfavoritedAndReloadsSnapshot() throws {
        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1"), ArchivedItem.build(remoteID: "2")]
        }

        source.stubFavoriteArchivedItem { _ in
            throw FakeError.error
        }

        let viewModel = subject()
        awaitInitialSnapshot(viewModel)

        let expectSnapshotWithReloadedItem = expectation(description: "expected reloaded item snapshot")
        expectSnapshotWithReloadedItem.expectedFulfillmentCount = 2
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item("1"), .item("2")])
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [.item("1")])
            expectSnapshotWithReloadedItem.fulfill()
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: "1")?.handler?(nil)
        wait(for: [expectSnapshotWithReloadedItem], timeout: 1)

        XCTAssertEqual(viewModel.favoriteAction(for: "1")?.title, "Favorite")

        XCTAssertNotNil(viewModel.presentedAlert)
        viewModel.presentedAlert?.actions.first?.invoke()
        XCTAssertNil(viewModel.presentedAlert)
    }

    func tests_favoriteAction_whenItemIsFavorited_delegatesToSource_andUpdatesSnapshot() throws {
        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1", isFavorite: true), ArchivedItem.build(remoteID: "2")]
        }

        source.stubUnfavoriteArchivedItem { _ in

        }

        let viewModel = subject()
        awaitInitialSnapshot(viewModel)

        let expectSnapshotWithReloadedItem = expectation(description: "expected reloaded item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item("1"), .item("2")]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                [.item("1")]
            )

            expectSnapshotWithReloadedItem.fulfill()
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: "1")?.handler?(nil)

        let predicate = NSPredicate { _, _ in self.source.unfavoriteArchivedItemCall(at: 0) != nil }
        wait(for: [
            expectSnapshotWithReloadedItem,
            expectation(for: predicate, evaluatedWith: nil)
        ], timeout: 2, enforceOrder: true)

        XCTAssertEqual(viewModel.favoriteAction(for: "1")?.title, "Favorite")
    }

    private func awaitInitialSnapshot(_ viewModel: ArchivedItemsListViewModel) {
        let expectEmptySnapshot = expectation(description: "expect empty snapshot")
        let expectInitialSnapshot = expectation(description: "expect initial snapshot")
        let initialLoadSubscription = viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            if snapshot.itemIdentifiers(inSection: .items).isEmpty {
                expectEmptySnapshot.fulfill()
                return
            }

            if snapshot.itemIdentifiers(inSection: .items).count == 2 {
                expectInitialSnapshot.fulfill()
                return
            }

            XCTFail("Received unexepected snapshot event: \(snapshot)")
        }

        viewModel.fetch()
        wait(for: [expectEmptySnapshot, expectInitialSnapshot], timeout: 1)
        initialLoadSubscription.cancel()
    }
}
