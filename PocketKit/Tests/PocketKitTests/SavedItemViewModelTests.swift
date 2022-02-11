import XCTest
import Sync
import Analytics
import Combine

@testable import PocketKit


class SavedItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(item: SavedItem, source: Source? = nil, tracker: Tracker? = nil) -> SavedItemViewModel {
        SavedItemViewModel(
            item: item,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_init_buildsCorrectActions() {
        // not-favorited, not-archived
        do {
            let viewModel = subject(item: .build(isFavorite: false, isArchived: false))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Favorite", "Archive", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let viewModel = subject(item: .build(isFavorite: true, isArchived: true))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Unfavorite", "Re-add", "Delete", "Share"]
            )
        }
    }

    func test_whenItemChanges_rebuildsActions() {
        let item: SavedItem = .build(isFavorite: false, isArchived: true)
        let viewModel = subject(item: item)

        item.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Re-add", "Delete", "Share"]
        )

        item.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Archive", "Delete", "Share"]
        )
    }

    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let viewModel = subject(item: .build())
        viewModel.invokeAction(title: "Display Settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    func test_favorite_delegatesToSource() {
        let item: SavedItem = .build(isFavorite: false)
        let expectFavorite = expectation(description: "expect source.favorite(_:)")

        source.stubFavoriteSavedItem { favoritedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 1)
    }

    func test_unfavorite_delegatesToSource() {
        let item: SavedItem = .build(isFavorite: true)
        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_delete_delegatesToSource_andSendsDeleteEvent() {
        let item: SavedItem = .build(isFavorite: true)
        let viewModel = subject(item: item)

        let expectDelete = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { deletedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedItem === item)
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
        let item: SavedItem = .build(isArchived: false)
        let viewModel = subject(item: item)

        let expectArchive = expectation(description: "expect source.archive(_:)")
        source.stubArchiveSavedItem { archivedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedItem === item)
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

    func test_reAdd_sendsRequestToSource_AndRefreshes() {
        let item: SavedItem = .build(isArchived: true)
        let expectUnarchive = expectation(description: "expect source.unarchive(_:)")

        source.stubUnarchiveSavedItem { unarchivedItem in
            defer { expectUnarchive.fulfill() }
            XCTAssertTrue(unarchivedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Re-add")

        wait(for: [expectUnarchive], timeout: 1)
    }

    func test_share_updatesSharedActivity() {
        let viewModel = subject(item: .build())
        viewModel.invokeAction(title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item: SavedItem = .build()
        let viewModel = subject(item: item)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL, item.bestURL)
    }
}

extension SavedItemViewModel {
    func invokeAction(title: String) {
        _actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
