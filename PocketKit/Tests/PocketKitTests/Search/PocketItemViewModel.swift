import XCTest
import Analytics

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
        tracker: Tracker? = nil
    ) -> PocketItemViewModel {
        PocketItemViewModel(
            item: item,
            index: index,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
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

        _ = viewModel.favoriteAction(index: 0, scope: .saves).handler?(nil)

        wait(for: [expectFavoriteCall, expectFetchSavedItemCall], timeout: 1)
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

        _ = viewModel.favoriteAction(index: 0, scope: .saves).handler?(nil)

        wait(for: [expectUnfavoriteCall, expectFetchSavedItemCall], timeout: 1)
        XCTAssertEqual(source.unfavoriteSavedItemCall(at: 0)?.item, item)
        XCTAssertFalse(viewModel.isFavorite)
    }
}
