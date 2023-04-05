import XCTest
import CoreData
import Analytics
import Combine
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class SavedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var space: Space!
    var refreshCoordinator: AbstractRefreshCoordinatorProtocol!
    var appSession: AppSession!

    var tracker: MockTracker!
    var itemsController: FetchedSavedItemsController!
    var listOptions: ListOptions!
    var viewType: SavesViewType!
    var subscriptions: [AnyCancellable]!
    var user: User!
    var userDefaults: UserDefaults!

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()
        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.currentSession = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        refreshCoordinator = SavesRefreshCoordinator(notificationCenter: .default, taskScheduler: MockBGTaskScheduler(), appSession: appSession, source: source)
        subscriptions = []
        viewType = .saves
        userDefaults = .standard
        user = PocketUser(userDefaults: userDefaults)
        listOptions = .saved(userDefaults: userDefaults)
        listOptions.selectedSortOption = .newest

        itemsController = FetchedSavedItemsController(resultsController: NSFetchedResultsController(
            fetchRequest: Requests.fetchSavedItems(),
            managedObjectContext: space.backgroundContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        ))

       // itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeSavesController {
            self.itemsController
        }

        source.stubMakeArchiveController {
            self.itemsController
        }

        source.stubViewObject { identifier in
            self.space.viewObject(with: identifier)
        }

        source.stubBackgroundObject { identifier in
            self.space.backgroundObject(with: identifier)
        }
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
        try space.save()
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        listOptions: ListOptions? = nil,
        viewType: SavesViewType? = nil,
        user: User? = nil,
        userDefaults: UserDefaults? = nil
    ) -> SavedItemsListViewModel {
        SavedItemsListViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            viewType: viewType ?? self.viewType,
            listOptions: listOptions ?? self.listOptions,
            notificationCenter: .default,
            user: user ?? self.user,
            refreshCoordinator: refreshCoordinator,
            userDefaults: userDefaults ?? self.userDefaults
        )
    }

    func test_applySortingOnSavesSavedItems() throws {
        _ = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0))
            )
        }
        try space.save()

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { [unowned self] snapshot in
            XCTAssertEqual(
                self.itemsController.sortDescriptors,
                [NSSortDescriptor(keyPath: \SavedItem.createdAt, ascending: true)]
            )

            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        listOptions.selectedSortOption = .oldest

        wait(for: [snapshotSent], timeout: 10)
    }

    func test_shouldSelectCell_whenItemIsPending_returnsFalse() throws {
        let viewModel = subject()
        let item = space.buildPendingSavedItem()
        try space.save()

        XCTAssertFalse(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_shouldSelectCell_whenItemIsNotPending_returnsFalse() throws {
        let viewModel = subject()

        let item = space.buildSavedItem(item: nil)
        try space.save()

        XCTAssertTrue(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_selectCell_whenItemIsArticle_setsSelectedItemToReaderView() throws {
        let viewModel = subject()
        let item = space.buildPendingSavedItem()
        try space.save()
        viewModel.selectCell(with: .item(item.objectID), sender: UIView())

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

    func test_selectCell_whenItemIsNotAnArticle_setsSelectedItemToWebView() throws {
        let viewModel = subject()
        let item = space.buildItem(isArticle: false)
        let savedItem = space.buildSavedItem(item: item)
        try space.save()

        viewModel.selectCell(with: .item(savedItem.objectID), sender: UIView())

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
        wait(for: [eventSent], timeout: 10)
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
        wait(for: [eventSent], timeout: 10)
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
        wait(for: [eventSent], timeout: 10)
    }

    func test_sourceEvents_whenEventIsSavedItemCreated_sendsSnapshotWithNewItem() {
        let savedItem = space.buildSavedItem()

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let itemIDs = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(itemIDs, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        try? space.save()
        source._events.send(.savedItemCreated)

        wait(for: [snapshotSent], timeout: 10)
    }

    func test_sourceEvents_whenEventIsSavedItemUpdated_sendsSnapshotWithUpdatedItem() {
        let savedItem = space.buildSavedItem()
        try? space.save()

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { [unowned self] snapshot in
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items).first, .item(savedItem.objectID))
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemsUpdated([savedItem]))

        wait(for: [snapshotSent], timeout: 10)
    }

    func test_receivedSnapshots_withNoItems_includesSavesEmptyState() {
        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .emptyState)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertTrue(snapshot.sectionIdentifiers.contains(.emptyState))
            XCTAssertNotNil(viewModel.emptyState)
            XCTAssertTrue(viewModel.emptyState is SavesEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        try? itemsController.performFetch()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_receivedSnapshots_withNoItems_includesFavoritesEmptyState() {
        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites), sender: UIView())

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .emptyState)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertTrue(snapshot.sectionIdentifiers.contains(.emptyState))
            XCTAssertNotNil(viewModel.emptyState)
            XCTAssertTrue(viewModel.emptyState is FavoritesEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        try? itemsController.performFetch()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_receivedSnapshots_withNoItems_includesTagsEmptyState() {
        source.stubFetchAllTags {
            []
        }
        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.tagged), sender: UIView())

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .emptyState)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertTrue(snapshot.sectionIdentifiers.contains(.emptyState))
            XCTAssertNotNil(viewModel.emptyState)
            XCTAssertTrue(viewModel.emptyState is TagsEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        try? itemsController.performFetch()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_receivedSnapshots_withItems_doesNotIncludeSavesEmptyState() {
        _ = space.buildSavedItem()
        try? space.save()

        let viewModel = subject()
        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertNil(snapshot.indexOfSection(.emptyState))
            XCTAssertNil(viewModel.emptyState)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        try? itemsController.performFetch()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_receivedSnapshots_withItems_doesNotIncludeFavoritesEmptyState() {
        _ = space.buildSavedItem(isFavorite: true)
        try? space.save()

        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites), sender: UIView())

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertNil(snapshot.indexOfSection(.emptyState))
            XCTAssertNil(viewModel.emptyState)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        try? itemsController.performFetch()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_refreshSaves_callsRetryImmediatelyOnSource() {
        source.stubRefreshSaves { _ in }
        source.stubRetryImmediately { }

        let viewModel = subject()
        viewModel.refresh()

        XCTAssertNotNil(source.retryImmediatelyCall(at: 0))
    }

    func test_receivedSnapshots_whenInitialDownloadIsInProgress_insertsPlaceholderCells() throws {
        let savedItem = space.buildSavedItem()
        try? space.save()

        let viewModel = subject()
        viewModel.fetch()

        let receivedSnapshot = expectation(description: "receivedSnapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { receivedSnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                [.item(savedItem.objectID), .placeholder(1)]
            )
        }.store(in: &subscriptions)

        source.initialSavesDownloadState.send(.paginating(totalCount: 2))
        try? itemsController.performFetch()

        wait(for: [receivedSnapshot], timeout: 10)
    }

    func test_receivedSnapshots_whenSavesInitialDownloadIsStarted_insertsPlaceholderCells() throws {
        source.initialSavesDownloadState.send(.started)

        let viewModel = subject()

        let receivedSnapshot = expectation(description: "receivedSnapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { receivedSnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                (0...3).map { .placeholder($0) }
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedSnapshot], timeout: 10)
    }

    func test_receivedSnapshots_whenArchiveInitialDownloadIsStarted_insertsPlaceholderCells() throws {
        source.initialArchiveDownloadState.send(.started)

        let viewModel = subject(listOptions: .archived(userDefaults: userDefaults), viewType: .archive)

        let receivedSnapshot = expectation(description: "receivedSnapshot")
        viewModel.snapshot.dropFirst().sink { snapshot in
            defer { receivedSnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .items),
                (0...3).map { .placeholder($0) }
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedSnapshot], timeout: 10)
    }
}

// MARK: - Tags
extension SavedItemsListViewModelTests {
    func test_addTagsAction_sendsAddTagsViewModel() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()

        source.stubRetrieveTags { _ in return nil }
        let viewModel = subject()

        let expectAddTags = expectation(description: "expect add tags to present")
        viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            defer { expectAddTags.fulfill() }
            XCTAssertEqual(viewModel?.tags, ["tag 1"])
        }.store(in: &subscriptions)

        viewModel.overflowActions(for: item.objectID)
            .first { $0.title == "Add Tags" }?
            .handler?(nil)

        wait(for: [expectAddTags], timeout: 10)
    }

    func test_fetch_whenTaggedSelected_sendsTagsFilterViewModel() throws {
        source.stubFetchAllTags {
            []
        }
        let viewModel = subject()

        let expectTagFiltersCall = expectation(description: "expect filter tag to present")
        viewModel.$presentedTagsFilter.dropFirst().sink { viewModel in
            defer { expectTagFiltersCall.fulfill() }
            XCTAssertNotNil(viewModel)
        }.store(in: &subscriptions)

        viewModel.selectCell(with: .filterButton(.tagged))

        wait(for: [expectTagFiltersCall], timeout: 10)
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

extension UIAction {
    private typealias Handler = @convention(block) (UIAction) -> Void

    func invoke() {
        if let block = value(forKey: "handler") {
            let blockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
            let handler = unsafeBitCast(blockPtr, to: Handler.self)
            handler(self)
        }
    }
}
