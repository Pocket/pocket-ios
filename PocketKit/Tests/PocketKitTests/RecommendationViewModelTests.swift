import XCTest
import Sync
import Analytics
import Combine

@testable import PocketKit


class RecommendationViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()

        continueAfterFailure = false
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        recommendation: Recommendation,
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> RecommendationViewModel {
        RecommendationViewModel(
            recommendation: recommendation,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_init_buildsCorrectActions() {
        // not saved
        do {
            let recommendation: Recommendation = .build(item: .build())
            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Save", "Share"]
            )
        }

        // not-favorited, not-archived
        do {
            let item: Item = .build()
            let savedItem: SavedItem = .build(isFavorite: false, isArchived: false, item: item)
            savedItem.item = item
            let recommendation: Recommendation = .build(item: item)
            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Favorite", "Archive", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let item: Item = .build()
            let savedItem: SavedItem = .build(isFavorite: true, isArchived: true, item: item)
            savedItem.item = item
            let recommendation: Recommendation = .build(item: item)
            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Unfavorite", "Move to My List", "Delete", "Share"]
            )
        }
    }

    func test_whenItemChanges_rebuildsActions() {
        let item: Item = .build()
        let recommendation: Recommendation = .build(item: item)
        let viewModel = subject(recommendation: recommendation)

        let savedItem: SavedItem = .build(isFavorite: false, isArchived: true, item: item)
        savedItem.item = item

        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Favorite", "Move to My List", "Delete", "Share"]
        )

        savedItem.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Move to My List", "Delete", "Share"]
        )

        savedItem.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Archive", "Delete", "Share"]
        )

        item.savedItem = nil
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Save", "Share"]
        )

        item.savedItem = savedItem
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Archive", "Delete", "Share"]
        )
    }

    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)
        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Display Settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    func test_favorite_delegatesToSource() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(isFavorite: false, item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)

        let expectFavorite = expectation(description: "expect source.favorite(_:)")
        source.stubFavoriteSavedItem { favoritedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedItem === savedItem)
        }

        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 1)
    }

    func test_unfavorite_delegatesToSource() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(isFavorite: true, item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)

        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")
        source.stubUnfavoriteSavedItem { unfavoritedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedItem === savedItem)
        }

        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_delete_delegatesToSource_andSendsDeleteEvent() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)
        let viewModel = subject(recommendation: recommendation)

        let expectDelete = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { deletedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedItem === savedItem)
        }

        let expectDeleteEvent = expectation(description: "expect delete event")
        viewModel.events.sink { event in
            guard case .delete = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            expectDeleteEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Delete")
        viewModel.presentedAlert?.actions.first { $0.title == "Yes" }?.invoke()

        wait(for: [expectDelete, expectDeleteEvent], timeout: 1)
    }

    func test_archive_sendsRequestToSource_andSendsArchiveEvent() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)
        let viewModel = subject(recommendation: recommendation)

        let expectArchive = expectation(description: "expect source.archive(_:)")
        source.stubArchiveSavedItem { archivedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedItem === savedItem)
        }

        let expectArchiveEvent = expectation(description: "expect archive event")
        viewModel.events.sink { event in
            guard case .archive = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            expectArchiveEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Archive")
        wait(for: [expectArchive, expectArchiveEvent], timeout: 1)
    }

    func test_moveToMyList_sendsRequestToSource_AndRefreshes() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(isArchived: true, item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)

        let expectUnarchive = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { unarchivedItem in
            defer { expectUnarchive.fulfill() }
            XCTAssertTrue(unarchivedItem === savedItem)
        }

        let viewModel = subject(recommendation: recommendation)
        viewModel.invokeAction(title: "Move to My List")

        wait(for: [expectUnarchive], timeout: 1)
    }

    func test_share_updatesSharedActivity() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)

        let viewModel = subject(recommendation: recommendation)
        viewModel.invokeAction(title: "Share")

        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item: Item = .build()
        let savedItem: SavedItem = .build(item: item)
        savedItem.item = item
        let recommendation: Recommendation = .build(item: item)

        let viewModel = subject(recommendation: recommendation)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL, item.bestURL)
    }

    func test_save_delegatesToSource() {
        let recommendation: Recommendation = .build(item: .build())

        let expectSave = expectation(description: "expect source.save(_:)")
        source.stubSaveRecommendation { saved in
            defer { expectSave.fulfill() }
            XCTAssertTrue(saved === recommendation)
        }

        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Save")

        wait(for: [expectSave], timeout: 1)
    }
}

extension RecommendationViewModel {
    func invokeAction(title: String) {
        _actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
