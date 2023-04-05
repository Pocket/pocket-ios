import XCTest
import Analytics
import SharedPocketKit

@testable import PocketKit
@testable import Sync

class PocketItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    var space: Space!

    override func setUpWithError() throws {
        source = MockSource()
        tracker = MockTracker()
        self.space = .testSpace()
    }

    override func tearDownWithError() throws {
        source = nil
        tracker = nil
        try space.clear()
    }

    func subject(
        item: PocketItem,
        index: Int = 0,
        source: Source? = nil,
        tracker: Tracker? = nil,
        scope: SearchScope? = nil
    ) -> PocketItemViewModel {
        PocketItemViewModel(
            item: item,
            index: index,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            scope: scope ?? .saves
        )
    }

    func test_favoriteAction_delegatesToSource_updatesPublishedProperty() {
        let item = space.buildSavedItem()

        let expectFavoriteCall = expectation(description: "expect source.favorite(_:)")
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")
        source.stubFavoriteSavedItem { item in
            defer { expectFavoriteCall.fulfill() }
            item.isFavorite = true
        }

        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))

        _ = viewModel.favoriteAction().handler?(nil)

        wait(for: [expectFavoriteCall, expectFetchSavedItemCall], timeout: 10)
        XCTAssertEqual(source.favoriteSavedItemCall(at: 0)?.item, item)
        XCTAssertTrue(viewModel.isFavorite)
    }

    func test_unfavoriteAction_delegatesToSource_updatesPublishedProperty() {
        let item = space.buildSavedItem(isFavorite: true)

        let expectUnfavoriteCall = expectation(description: "expect source.unfavorite(_:)")
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")
        source.stubUnfavoriteSavedItem { item in
            defer { expectUnfavoriteCall.fulfill() }
            item.isFavorite = false
        }

        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))

        _ = viewModel.favoriteAction().handler?(nil)

        wait(for: [expectUnfavoriteCall, expectFetchSavedItemCall], timeout: 10)
        XCTAssertEqual(source.unfavoriteSavedItemCall(at: 0)?.item, item)
        XCTAssertFalse(viewModel.isFavorite)
    }

    func test_shareAction_presentsShareSheet() {
        let item = space.buildSavedItem()

        let viewModel = subject(item: PocketItem(item: item))

        _ = viewModel.shareAction().handler?(nil)

        XCTAssertTrue(viewModel.presentShareSheet)
    }

    func test_addTagsAction_sendsAddTagsViewModel() {
        let item = space.buildSavedItem(tags: ["tag-0"])
        source.stubRetrieveTags { _ in return nil }
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")
        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))
        guard let tagsViewModel = viewModel.tagsViewModel else {
            XCTFail("Should not be nil")
            return
        }
        wait(for: [expectFetchSavedItemCall], timeout: 10)
        XCTAssertEqual(tagsViewModel.tags, ["tag-0"])
    }

    func test_archiveAction_delegatesToSource() {
        let item = space.buildSavedItem()
        let expectArchive = expectation(description: "expect source.archive(_:)")
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")
        source.stubArchiveSavedItem { archivedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedItem === item)
        }

        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))
        viewModel.archive()

        wait(for: [expectArchive, expectFetchSavedItemCall], timeout: 10)
    }

    func test_unarchiveAction_delegatesToSource() {
        let item = space.buildSavedItem()
        let expectUnarchive = expectation(description: "expect source.unarchive(_:)")
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")
        source.stubUnarchiveSavedItem { unarchivedItem in
            defer { expectUnarchive.fulfill() }
            XCTAssertTrue(unarchivedItem === item)
        }

        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))
        viewModel.moveToSaves()

        wait(for: [expectUnarchive, expectFetchSavedItemCall], timeout: 10)
    }

    func test_deleteAction_delegatesToSource() {
        let item = space.buildSavedItem()
        let expectDelete = expectation(description: "expect source.delete(_:)")
        let expectFetchSavedItemCall = expectation(description: "expect source.fetchOrCreateSavedItem(_:)")

        source.stubDeleteSavedItem { deletedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedItem === item)
        }

        source.stubFetchSavedItem { _ in
            defer { expectFetchSavedItemCall.fulfill() }
            return item
        }

        let viewModel = subject(item: PocketItem(item: item))
        viewModel.delete()

        wait(for: [expectDelete, expectFetchSavedItemCall], timeout: 10)
    }
}
