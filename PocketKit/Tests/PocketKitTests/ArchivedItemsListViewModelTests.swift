import XCTest
import Sync
import Combine
import Network
import Analytics

@testable import PocketKit

enum FakeError: Error {
    case error
}

class ArchivedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var networkMonitor: MockNetworkPathMonitor!
    var itemsController: MockSavedItemsController!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
        self.tracker = MockTracker()
        self.networkMonitor = MockNetworkPathMonitor()

        self.itemsController = MockSavedItemsController()
        self.itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeItemsController { self.itemsController }
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

    func test_initializing_configuresTheItemsController() {
        _ = subject()
        XCTAssertEqual(itemsController.predicate, Predicates.archivedItems())
    }

    func test_fetch_delegatesToSource() {
        itemsController.stubPerformFetch { }
        source.stubFetchArchivePage { _, _ in }

        let viewModel = subject()
        viewModel.fetch()

        XCTAssertNotNil(itemsController.performFetchCall(at: 0))
    }

    func test_fetch_whenOffline_showsOfflineMessage() {
        itemsController.stubPerformFetch { XCTFail("Should not fetch local items when offline") }
        networkMonitor.update(status: .unsatisfied)
        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else { return }
            defer { expectSnapshot.fulfill() }

            XCTAssertEqual(snapshot.sectionIdentifiers, [.offline])
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .offline),
                [.offline]
            )
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [expectSnapshot], timeout: 1)
    }

    func test_changedContentFromItemsController_sendsNewSnapshot() {
        let itemsController = MockSavedItemsController()
        source.stubMakeItemsController { itemsController }

        let items: [SavedItem] = [.build(), .build()]

        let expectSnapshot = expectation(description: "expect a snapshot")
        let viewModel = subject()
        viewModel.events.compactMap { event -> ArchivedItemsListViewModel.Snapshot? in
            guard case .snapshot(let snapshot) = event else {
                return nil
            }

            return snapshot
        }.sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [
                    .item(items[0].objectID),
                    .item(items[1].objectID),
                ]
            )

            expectSnapshot.fulfill()
        }.store(in: &subscriptions)

        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [expectSnapshot], timeout: 1)
        XCTAssertNotNil(viewModel.item(with: items[0].objectID))
    }

    func test_shareAction_setsSharedActivity() {
        let viewModel = subject()

        let items: [SavedItem] = [.build(), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        viewModel.shareAction(for: items[0].objectID)?.handler?(nil)
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_deleteAction_delegatesToSource_andUpdatesSnapshot() {
        let viewModel = subject()

        let items: [SavedItem] = [.build(), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        let expectDeleteCall = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { item in
            defer { expectDeleteCall.fulfill() }
            self.itemsController.fetchedObjects = [items[1]]
            self.itemsController.delegate?.controllerDidChangeContent(self.itemsController)
        }

        let expectSnapshotWithItemRemoved = expectation(description: "expected deleted item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item(items[1].objectID)])
            expectSnapshotWithItemRemoved.fulfill()
        }.store(in: &subscriptions)

        // Tap delete button in overflow menu
        viewModel.overflowActions(for: items[0].objectID)?
            .first { $0.title == "Delete" }?
            .handler?(nil)

        // Tap "Yes" on confirmation alert
        viewModel.presentedAlert?
            .actions
            .first { $0.title == "Yes" }?.invoke()

        wait(for: [
            expectSnapshotWithItemRemoved,
            expectDeleteCall
        ], timeout: 1)

        XCTAssertEqual(source.deleteSavedItemCall(at: 0)?.item, items[0])
    }

    func tests_favoriteAction_delegatesToSource_andUpdatesSnapshot() throws {
        let viewModel = subject()

        let items: [SavedItem] = [.build(), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        let expectFavoriteCall = expectation(description: "expect source.favorite(_:)")
        source.stubFavoriteSavedItem { item in
            defer { expectFavoriteCall.fulfill() }
            self.itemsController.delegate?.controller(
                self.itemsController,
                didChange: item,
                at: [0, 0],
                for: .update,
                newIndexPath: nil
            )
        }

        let expectSnapshotWithItemReloaded = expectation(description: "expected reloaded item in snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            defer { expectSnapshotWithItemReloaded.fulfill() }
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [
                .item(items[0].objectID), .item(items[1].objectID)
            ])
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [
                .item(items[0].objectID)
            ])
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: items[0].objectID)?.handler?(nil)
        wait(for: [expectFavoriteCall, expectSnapshotWithItemReloaded], timeout: 1)
        XCTAssertEqual(source.favoriteSavedItemCall(at: 0)?.item, items[0])
    }

    func test_favoriteAction_whenItemIsFavorited_delegatesToSource_andUpdatesSnapshot() throws {
        let viewModel = subject()

        let items: [SavedItem] = [.build(isFavorite: true), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        let expectUnfavoriteCall = expectation(description: "expect source.favorite(_:)")
        source.stubUnfavoriteSavedItem { item in
            defer { expectUnfavoriteCall.fulfill() }
            self.itemsController.delegate?.controller(
                self.itemsController,
                didChange: item,
                at: [0, 0],
                for: .update,
                newIndexPath: nil
            )
        }

        let expectSnapshotWithItemReloaded = expectation(description: "expected reloaded item in snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }
            defer { expectSnapshotWithItemReloaded.fulfill() }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [
                .item(items[0].objectID), .item(items[1].objectID)
            ])
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [
                .item(items[0].objectID)
            ])
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: items[0].objectID)?.handler?(nil)
        wait(for: [expectUnfavoriteCall, expectSnapshotWithItemReloaded], timeout: 1)
        XCTAssertEqual(source.unfavoriteSavedItemCall(at: 0)?.item, items[0])
    }

    func test_reAddAction_removeItemAndDelegatesToSource() {
        let viewModel = subject()
        let items: [SavedItem] = [.build(isFavorite: true), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        let expectUnarchiveCall = expectation(description: "Expect a call to source.unarchive(_:)")
        source.stubUnarchiveSavedItem { _ in
            defer { expectUnarchiveCall.fulfill() }
            self.itemsController.fetchedObjects = [items[1]]
            self.itemsController.delegate?.controllerDidChangeContent(self.itemsController)
        }

        let expectSnapshotWithItemRemoved = expectation(description: "expected reloaded item snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }
            defer { expectSnapshotWithItemRemoved.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item(items[1].objectID)]
            )
        }.store(in: &subscriptions)

        viewModel.overflowActions(for: items[0].objectID)?
            .first { $0.title == "Re-add" }?
            .handler?(nil)

        wait(for: [expectUnarchiveCall, expectSnapshotWithItemRemoved], timeout: 1)
    }

    func test_selectCell_setsSelectedReadableToCorrespondingItem() {
        let viewModel = subject()
        let items: [SavedItem] = [.build(isFavorite: true), .build()]
        itemsController.fetchedObjects = items
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        viewModel.selectCell(with: .item(items[0].objectID))
        XCTAssertNotNil(viewModel.selectedReadable)
    }

    func test_receivedSnapshots_includeNextPageItem() {
        let items: [SavedItem] = [.build(cursor: "cursor-1"), .build(cursor: "cursor-2")]
        let itemsController = MockSavedItemsController()
        itemsController.fetchedObjects = items
        source.stubMakeItemsController { itemsController }

        source.stubFetchArchivePage { cursor, isFavorite in }

        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect a snapshot")
        viewModel.events.compactMap { event -> ArchivedItemsListViewModel.Snapshot? in
            guard case .snapshot(let snapshot) = event else { return nil }
            return snapshot
        }.sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .nextPage)
            XCTAssertEqual(identifiers.count, 1)
            guard case .nextPage = identifiers[0] else {
                XCTFail("received unexpected cell identifier: \(identifiers[0])")
                return
            }

            expectSnapshot.fulfill()
        }.store(in: &subscriptions)

        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [expectSnapshot], timeout: 1)

        viewModel.willDisplay(.nextPage)

        let call = source.fetchArchivePageCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertNil(call?.isFavorite)
        XCTAssertEqual(call?.cursor, "cursor-2")
    }

    func test_willDisplay_whenFavoritesFilterIsOn_includesFilterArgument() {
        let items: [SavedItem] = [.build(cursor: "cursor-1"), .build(cursor: "cursor-2")]
        let itemsController = MockSavedItemsController()
        itemsController.stubPerformFetch { itemsController.fetchedObjects = items }
        source.stubMakeItemsController { itemsController }

        source.stubFetchArchivePage { cursor, isFavorite in }

        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites))

        let nextPage = ItemsListCell<ArchivedItemsListViewModel.ItemIdentifier>.nextPage
        viewModel.willDisplay(nextPage)
        viewModel.willDisplay(nextPage)

        let call = source.fetchArchivePageCall(at: 0)
        XCTAssertEqual(call?.isFavorite, true)
        XCTAssertNil(source.fetchArchivePageCall(at:1))

        source._events.send(.loadedArchivePage)

        viewModel.willDisplay(nextPage)
        XCTAssertNotNil(source.fetchArchivePageCall(at:1))
    }

    func test_willDisplay_whenOffline_doesNothing() {
        let items: [SavedItem] = [.build(cursor: "cursor-1"), .build(cursor: "cursor-2")]
        let itemsController = MockSavedItemsController()
        itemsController.stubPerformFetch { itemsController.fetchedObjects = items }
        source.stubMakeItemsController { itemsController }

        let viewModel = subject()
        viewModel.fetch()

        networkMonitor.update(status: .unsatisfied)
        viewModel.willDisplay(.nextPage)

        XCTAssertNil(source.fetchArchivePageCall(at: 0))
    }

    func test_refresh_whenLocalItemsHavePreviouslyBeenFetched_delegatesToSource_andSendsASnapshot() {
        let items: [SavedItem] = [.build()]
        itemsController.fetchedObjects = items
        source.stubRefresh { _, completion in completion?() }
        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect a snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else { return }
            defer { expectSnapshot.fulfill() }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item(items[0].objectID)])
        }.store(in: &subscriptions)

        let expectCompletion = expectation(description: "Expect completion to be called")
        viewModel.refresh {
            expectCompletion.fulfill()
        }

        XCTAssertNotNil(source.refreshCall(at: 0))
        wait(for: [expectCompletion, expectSnapshot], timeout: 1)
    }

    func test_refresh_whenLocalItemsHaveNotBeenFetched_delegatesToSource_fetchesLocalItems() {
        let items: [SavedItem] = [.build()]

        source.stubRefresh { _, completion in completion?() }
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = items
        }

        let viewModel = subject()
        let expectSnapshot = expectation(description: "expect a snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else { return }
            defer { expectSnapshot.fulfill() }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item(items[0].objectID)])
        }.store(in: &subscriptions)

        let expectCompletion = expectation(description: "Expect completion to be called")
        viewModel.refresh {
            expectCompletion.fulfill()
        }

        XCTAssertNotNil(source.refreshCall(at: 0))
        wait(for: [expectCompletion, expectSnapshot], timeout: 1)
    }

    func test_refresh_whenOffline_showsTheOfflineMessage() {
        networkMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        let expectSnapshot = expectation(description: "expect snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else { return }
            defer { expectSnapshot.fulfill() }

            XCTAssertEqual(snapshot.sectionIdentifiers, [.offline])
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .offline),
                [.offline]
            )
        }.store(in: &subscriptions)

        let expectCompletion = expectation(description: "expect refresh to complete")
        viewModel.refresh {
            expectCompletion.fulfill()
        }
        wait(for: [expectCompletion, expectSnapshot], timeout: 1)
    }
}
