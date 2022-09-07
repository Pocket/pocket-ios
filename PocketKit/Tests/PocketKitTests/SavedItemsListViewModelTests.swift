import XCTest
import Analytics
import Sync
import Combine

@testable import Sync
@testable import PocketKit

class SavedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var space: Space!
    var tracker: MockTracker!
    var itemsController: MockSavedItemsController!
    var listOptions: ListOptions!
    var subscriptions: [AnyCancellable]!

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()
        subscriptions = []
        itemsController = MockSavedItemsController()
        listOptions = ListOptions()
        listOptions.selectedSort = .newest

        itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeItemsController {
            self.itemsController
        }
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        listOptions: ListOptions? = nil
    ) -> SavedItemsListViewModel {
        SavedItemsListViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            listOptions: listOptions ?? self.listOptions
        )
    }
    
    func test_applySortingOnMyListSavedItems() throws {
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0))
            )
        }
        try space.save()
        
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = savedItems
        }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { [unowned self] snapshot in
            XCTAssertEqual(
                self.itemsController.sortDescriptors,
                [NSSortDescriptor(keyPath: \SavedItem.createdAt, ascending: true)]
            )

            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        listOptions.selectedSort = .oldest

        wait(for: [snapshotSent], timeout: 1)
    }

    func test_shouldSelectCell_whenItemIsPending_returnsFalse() {
        let viewModel = subject()
        let item = space.buildPendingSavedItem()

        source.stubObject { _ in
            item
        }

        XCTAssertFalse(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_shouldSelectCell_whenItemIsNotPending_returnsFalse() {
        let viewModel = subject()

        let item = space.buildSavedItem(item: nil)

        source.stubObject { _ in item }

        XCTAssertTrue(viewModel.shouldSelectCell(with: .item(item.objectID)))
    }

    func test_selectCell_whenItemIsArticle_setsSelectedItemToReaderView() {
        let viewModel = subject()
        let item = space.buildPendingSavedItem()

        source.stubObject { _ in item }
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

    func test_selectCell_whenItemIsNotAnArticle_setsSelectedItemToWebView() {
        let viewModel = subject()
        let item = space.buildItem(isArticle: false)
        let savedItem = space.buildSavedItem(item: item)

        source.stubObject { _ in savedItem }
        viewModel.selectCell(with: .item(item.objectID), sender: UIView())

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

    func test_sourceEvents_whenEventIsSavedItemCreated_sendsSnapshotWithNewItem() {
        let savedItem = space.buildSavedItem()
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = [savedItem]
        }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let itemIDs = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(itemIDs, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemCreated)

        wait(for: [snapshotSent], timeout: 1)
    }

    func test_sourceEvents_whenEventIsSavedItemUpdated_sendsSnapshotWithUpdatedItem() {
        let savedItem = space.buildSavedItem()
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = [savedItem]
        }
        source.stubRefreshObject { _, _ in }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { [unowned self] snapshot in
            XCTAssertEqual(self.source.refreshObjectCall(at: 0)?.object, savedItem)
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemsUpdated([savedItem]))

        wait(for: [snapshotSent], timeout: 1)
    }

    func test_receivedSnapshots_withNoItems_includesMyListEmptyState() {
        itemsController.stubPerformFetch { [unowned self] in self.itemsController.fetchedObjects = [] }
        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .emptyState)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertTrue(snapshot.sectionIdentifiers.contains(.emptyState))
            XCTAssertNotNil(viewModel.emptyState)
            XCTAssertTrue(viewModel.emptyState is MyListEmptyStateViewModel)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withNoItems_includesFavoritesEmptyState() {
        itemsController.stubPerformFetch { [unowned self] in self.itemsController.fetchedObjects = [] }

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

        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withItems_doesNotIncludeMyListEmptyState() {
        let savedItem = space.buildSavedItem()
        itemsController.fetchedObjects = [savedItem]

        let viewModel = subject()
        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.snapshot.dropFirst().sink { snapshot in
            let identifiers = snapshot.itemIdentifiers(inSection: .items)
            XCTAssertEqual(identifiers.count, 1)
            XCTAssertNil(snapshot.indexOfSection(.emptyState))
            XCTAssertNil(viewModel.emptyState)
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_receivedSnapshots_withItems_doesNotIncludeFavoritesEmptyState() {
        let savedItem = space.buildSavedItem()

        itemsController.stubPerformFetch { [unowned self] in self.itemsController.fetchedObjects = [savedItem] }
        
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

        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_refresh_callsRetryImmediatelyOnSource() {
        source.stubRefresh { _, _ in }
        source.stubRetryImmediately { }

        let viewModel = subject()
        viewModel.refresh()

        XCTAssertNotNil(source.retryImmediatelyCall(at: 0))
    }

    func test_receivedSnapshots_whenInitialDownloadIsInProgress_insertsPlaceholderCells() throws {
        let savedItem = space.buildSavedItem()
        itemsController.stubPerformFetch { [unowned self] in
            self.itemsController.fetchedObjects = [savedItem]
        }

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

        source.initialDownloadState.send(.paginating(totalCount: 2))
        itemsController.delegate?.controllerDidChangeContent(itemsController)

        wait(for: [receivedSnapshot], timeout: 1)
    }

    func test_receivedSnapshots_whenInitialDownloadIsStarted_insertsPlaceholderCells() throws {
        source.initialDownloadState.send(.started)
        itemsController.stubPerformFetch { [unowned self] in
            self.itemsController.fetchedObjects = []
        }

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

        wait(for: [receivedSnapshot], timeout: 1)
    }

    func test_addTagsAction_sendsAddTagsViewModel() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubObject { _ in item }
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
}
