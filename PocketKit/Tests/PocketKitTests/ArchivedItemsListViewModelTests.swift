import XCTest
import Sync
import Combine
import Network
import Analytics

@testable import PocketKit
@testable import Sync

enum FakeError: Error {
    case error
}

class ArchivedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var space: Space!
    var tracker: MockTracker!
    var networkMonitor: MockNetworkPathMonitor!
    var archiveService: MockArchiveService!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
        self.tracker = MockTracker()
        self.networkMonitor = MockNetworkPathMonitor()
        self.archiveService = MockArchiveService()
        self.space = .testSpace()

        source.stubMakeArchiveService { self.archiveService }
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
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

    func test_fetch_delegatesToArchiveService() {
        archiveService.stubRefresh { _ in }

        let viewModel = subject()
        viewModel.fetch()

        let call = archiveService.refreshCall(at: 0)
        XCTAssertNotNil(call)
    }

    func test_fetch_whenOffline_showsOfflineMessage() {
        networkMonitor.update(status: .unsatisfied)

        archiveService.stubFetch { _ in
            XCTFail("Should not fetch archive when offline")
        }

        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
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

    func test_changedContentFromArchiveService_sendsNewSnapshot() {
        let items = [space.buildSavedItem(), space.buildSavedItem()]

        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect a snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [
                    .item(items[0].objectID),
                    .item(items[1].objectID),
                ]
            )

            expectSnapshot.fulfill()
        }.store(in: &subscriptions)

        archiveService._results = [.loaded(items[0]), .loaded(items[1])]
        wait(for: [expectSnapshot], timeout: 1)
    }

    func test_shareAction_setsSharedActivity() {
        let items = [space.buildSavedItem(), space.buildSavedItem()]

        let viewModel = subject()

        archiveService._results = items.map { .loaded($0) }
        viewModel.shareAction(for: items[0].objectID)?.handler?(nil)
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_deleteAction_delegatesToSource_andUpdatesSnapshot() {
        let items = [space.buildSavedItem(), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let expectDeleteCall = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { item in
            defer { expectDeleteCall.fulfill() }
            self.archiveService._results = [.loaded(items[1])]
        }

        let viewModel = subject()
        let expectSnapshotWithItemRemoved = expectation(description: "expected deleted item snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item(items[1].objectID)]
            )

            expectSnapshotWithItemRemoved.fulfill()
        }.store(in: &subscriptions)

        // Tap delete button in overflow menu
        viewModel.overflowActions(for: items[0].objectID)
            .first { $0.title == "Delete" }?
            .handler?(nil)

        // Tap "Yes" on confirmation alert
        viewModel.presentedAlert?
            .actions
            .first { $0.title == "Yes" }?.invoke()

        wait(
            for: [
                expectSnapshotWithItemRemoved,
                expectDeleteCall
            ],
            timeout: 1
        )

        XCTAssertEqual(source.deleteSavedItemCall(at: 0)?.item, items[0])
    }

    func tests_favoriteAction_delegatesToSource_andUpdatesSnapshot() throws {
        let items = [space.buildSavedItem(), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        let expectFavoriteCall = expectation(description: "expect source.favorite(_:)")
        source.stubFavoriteSavedItem { item in
            defer { expectFavoriteCall.fulfill() }
            item.isFavorite = true
            self.archiveService._itemUpdated.send(item)
        }

        let expectSnapshotWithItemReloaded = expectation(description: "expected reloaded item in snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { expectSnapshotWithItemReloaded.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [
                    .item(items[0].objectID),
                    .item(items[1].objectID)
                ]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                [
                    .item(items[0].objectID)
                ]
            )
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: items[0].objectID)?.handler?(nil)
        wait(for: [expectFavoriteCall, expectSnapshotWithItemReloaded], timeout: 1)
        XCTAssertEqual(source.favoriteSavedItemCall(at: 0)?.item, items[0])
    }

    func test_favoriteAction_whenItemIsFavorited_delegatesToSource_andUpdatesSnapshot() throws {
        let items = [space.buildSavedItem(isFavorite: true), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        let expectUnfavoriteCall = expectation(description: "expect source.favorite(_:)")
        source.stubUnfavoriteSavedItem { item in
            defer { expectUnfavoriteCall.fulfill() }
            item.isFavorite = false

            self.archiveService._itemUpdated.send(item)
        }

        let expectSnapshotWithItemReloaded = expectation(description: "expected reloaded item in snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { expectSnapshotWithItemReloaded.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [
                    .item(items[0].objectID),
                    .item(items[1].objectID)
                ]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                [
                    .item(items[0].objectID)
                ]
            )
        }.store(in: &subscriptions)

        viewModel.favoriteAction(for: items[0].objectID)?.handler?(nil)
        wait(for: [expectUnfavoriteCall, expectSnapshotWithItemReloaded], timeout: 1)
        XCTAssertEqual(source.unfavoriteSavedItemCall(at: 0)?.item, items[0])
    }

    func test_reAddAction_removeItemAndDelegatesToSource() {
        let items = [space.buildSavedItem(isFavorite: true), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        let expectUnarchiveCall = expectation(description: "Expect a call to source.unarchive(_:)")
        source.stubUnarchiveSavedItem { _ in
            defer { expectUnarchiveCall.fulfill() }
            self.archiveService._results = [.loaded(items[1])]
        }

        let expectSnapshotWithItemRemoved = expectation(description: "expected reloaded item snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { expectSnapshotWithItemRemoved.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item(items[1].objectID)]
            )
        }.store(in: &subscriptions)

        viewModel.overflowActions(for: items[0].objectID)
            .first { $0.title == "Move to My List" }?
            .handler?(nil)

        wait(for: [expectUnarchiveCall, expectSnapshotWithItemRemoved], timeout: 1)
    }

    func test_shouldSelectCell_whenItemIsPending_returnsFalse() {
        let items = [space.buildPendingSavedItem(), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        XCTAssertFalse(viewModel.shouldSelectCell(with: .item(items[0].objectID)))
    }

    func test_shouldSelectCell_whenItemIsNotPending_returnsFalse() {
        let items = [space.buildSavedItem(), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        XCTAssertTrue(viewModel.shouldSelectCell(with: .item(items[0].objectID)))
    }

    func test_selectCell_whenItemIsArticle_setsSelectedItemToReaderView() {
        let items = [
            space.buildSavedItem(item: space.buildItem(isArticle: true)),
            space.buildSavedItem()
        ]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()
        viewModel.selectCell(with: .item(items[0].objectID), sender: UIView())

        guard let selectedItem = viewModel.selectedItem else {
            XCTFail("Received nil for selectedItem")
            return
        }

        guard case .readable(let item) = selectedItem else {
            XCTFail("Received unexpected selectedItem: \(selectedItem)")
            return
        }

        XCTAssertNotNil(item)
    }

    func test_selectCell_whenItemIsNotAnArticle_setsSelectedItemToWebView() {
        let items = [space.buildSavedItem(item: space.buildItem(isArticle: false)), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()
        viewModel.selectCell(with: .item(items[0].objectID), sender: UIView())

        guard let selectedItem = viewModel.selectedItem else {
            XCTFail("Received nil for selectedItem")
            return
        }

        guard case .webView(let url) = selectedItem else {
            XCTFail("Received unexpected selectedItem: \(selectedItem)")
            return
        }

        XCTAssertNotNil(url)
    }

    func test_selectedItem_whenNil_sendsSelectionCleared() {
        let viewModel = subject()

        let eventSent = expectation(description: "selectionClearedSent")
        viewModel.events.sink { event in
            guard case .selectionCleared = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }
            eventSent.fulfill()
        }.store(in: &subscriptions)

        viewModel.selectedItem = nil
        wait(for: [eventSent], timeout: 1)
    }

    func test_selectedItem_whenReaderView_doesNotSendSelectionCleared() {
        let viewModel = subject()

        let eventSent = expectation(description: "selectionClearedSent")
        eventSent.isInverted = true
        viewModel.events.sink { event in
            XCTFail("Received unexpected event call: \(event)")
            eventSent.fulfill()
        }.store(in: &subscriptions)

        viewModel.selectedItem = .readable(nil)
        wait(for: [eventSent], timeout: 1)
    }

    func test_selectedItem_whenWebView_doesNotSendSelectionCleared() {
        let viewModel = subject()

        let eventSent = expectation(description: "selectionClearedSent")
        eventSent.isInverted = true
        viewModel.events.sink { event in
            XCTFail("Received unexpected event call: \(event)")
            eventSent.fulfill()
        }.store(in: &subscriptions)

        viewModel.selectedItem = .webView(nil)
        wait(for: [eventSent], timeout: 1)
    }

    func test_receivedSnapshots_withNoItems_includesArchiveEmptyState() {
        archiveService._results = []

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .emptyState),
                [.emptyState]
            )

            XCTAssertTrue(viewModel.emptyState is ArchiveEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withNoItems_includesFavoritesEmptyState() {
        archiveService._results = []

        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites), sender: UIView())

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .emptyState),
                [.emptyState]
            )

            XCTAssertTrue(viewModel.emptyState is FavoritesEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withItems_doesNotIncludeArchiveEmptyState() {
        let items = [space.buildSavedItem(), space.buildSavedItem()]
        archiveService._results = items.map { .loaded($0) }

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.sink { snapshot in
            XCTAssertNil(snapshot.indexOfSection(.emptyState))
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withNotLoadedItems_includesPlaceholderCells() {
        archiveService._results = [.notLoaded, .notLoaded]

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.placeholder(0), .placeholder(1)]
            )
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_prefetch_whenOffline_doesNothing() {
        archiveService.stubFetch { _ in }
        archiveService._results = [.loaded(space.buildSavedItem()), .notLoaded]
        networkMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.prefetch(itemsAt: [[0, 1]])

        XCTAssertNil(source.fetchArchivePageCall(at: 0))
    }

    func test_refresh_delegatesToArchiveService() {
        archiveService.stubRefresh { completion in
            completion?()
        }

        let viewModel = subject()

        let completionInvoked = expectation(description: "completionInvoked")
        viewModel.refresh {
            completionInvoked.fulfill()
        }

        wait(for: [completionInvoked], timeout: 1)
        XCTAssertNotNil(archiveService.refreshCall(at: 0))
    }

    func test_refresh_whenOffline_showsTheOfflineMessage() {
        networkMonitor.update(status: .unsatisfied)

        let viewModel = subject()

        let expectSnapshot = expectation(description: "expect snapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
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

// MARK: - Tags
extension ArchivedItemsListViewModelTests {
    func test_addTagsAction_sendsAddTagsViewModel() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        archiveService._results = [.loaded(item)]
        let viewModel = subject()

        let expectAddTags = expectation(description: "expect add tags to present")

        viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            expectAddTags.fulfill()
            XCTAssertEqual(viewModel?.tags, ["tag 1"])
        }.store(in: &subscriptions)

        viewModel.overflowActions(for: item.objectID)
            .first { $0.title == "Add Tags" }?
            .handler?(nil)

        wait(for: [expectAddTags], timeout: 1)
    }

    func test_fetch_whenTaggedSelected_sendsTagsFilterViewModel() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        archiveService._results = [.loaded(item)]
        source.stubFetchTags {
            []
        }
        let viewModel = subject()

        let expectTagFiltersCall = expectation(description: "expect filter tag to present")
        viewModel.$presentedTagsFilter.dropFirst().sink { viewModel in
            defer { expectTagFiltersCall.fulfill() }
            XCTAssertNotNil(viewModel)
        }.store(in: &subscriptions)

        viewModel.selectCell(with: .filterButton(.tagged))

        wait(for: [expectTagFiltersCall], timeout: 1)
    }

    func test_tagModel_calculatesTagHeightAndWidth() {
        let viewModel = subject()
        let model = viewModel.tagModel(with: "tag 0")

        let width = SelectedTagChipCell.width(model: model)
        let height = SelectedTagChipCell.height(model: model)
        XCTAssertEqual(width, 115.0)
        XCTAssertEqual(height, 39.0)
    }
}
