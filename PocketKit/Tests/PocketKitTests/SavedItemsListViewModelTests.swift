import XCTest
import Analytics
import Sync
@testable import PocketKit


class SavedItemsListViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var itemsController: MockSavedItemsController!

    override func setUp() {
        self.source = MockSource()
        self.tracker = MockTracker()

        self.itemsController = MockSavedItemsController()
        self.itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeItemsController { self.itemsController }
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
}
