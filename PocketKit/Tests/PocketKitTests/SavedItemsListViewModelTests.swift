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
    
    func test_selectCell_whenItemIsArticle_setsSelectedItemToReaderView() {
        let viewModel = subject()
        let item = SavedItem.build()
        
        source.stubObject { _ in item }
        
        viewModel.selectCell(with: .item(item.objectID))
        
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
        let item = SavedItem.build()
        item.item?.isArticle = false
        
        source.stubObject { _ in item }
        
        viewModel.selectCell(with: .item(item.objectID))
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
        let savedItem: SavedItem = .build()
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
        let savedItem: SavedItem = .build()
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = [savedItem]
        }
        source.stubRefreshObject { _, _ in }

        let viewModel = subject()

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.snapshot.dropFirst().sink { snapshot in
            XCTAssertEqual(self.source.refreshObjectCall(at: 0)?.object, savedItem)
            XCTAssertEqual(snapshot.reloadedItemIdentifiers, [.item(savedItem.objectID)])
            snapshotSent.fulfill()
        }.store(in: &subscriptions)

        source._events.send(.savedItemsUpdated([savedItem]))

        wait(for: [snapshotSent], timeout: 1)
    }
    
    func test_receivedSnapshots_withNoItems_includesMyListEmptyState() {
        itemsController.stubPerformFetch { self.itemsController.fetchedObjects = [] }
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
        itemsController.stubPerformFetch { self.itemsController.fetchedObjects = [] }
        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites))
        
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
        let savedItem: SavedItem = .build()
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
        let savedItem: SavedItem = .build()
        itemsController.stubPerformFetch { self.itemsController.fetchedObjects = [savedItem] }
        
        let viewModel = subject()
        viewModel.selectCell(with: .filterButton(.favorites))
        
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
}
