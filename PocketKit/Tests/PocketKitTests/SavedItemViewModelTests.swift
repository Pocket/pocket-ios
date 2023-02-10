import XCTest
import Analytics
import Combine

@testable import Sync
@testable import PocketKit

class SavedItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var space: Space!
    private var pasteboard: Pasteboard!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        pasteboard = MockPasteboard()
        space = .testSpace()
    }

    override func tearDown() async throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        item: SavedItem,
        source: Source? = nil,
        tracker: Tracker? = nil,
        pasteboard: UIPasteboard? = nil
    ) -> SavedItemViewModel {
        SavedItemViewModel(
            item: item,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            pasteboard: pasteboard ?? self.pasteboard
        )
    }

    func test_init_buildsCorrectActions() {
        // not-favorited, not-archived
        do {
            let viewModel = subject(item: space.buildSavedItem(isFavorite: false, isArchived: false))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Favorite", "Add Tags", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let viewModel = subject(item: space.buildSavedItem(isFavorite: true, isArchived: true))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Unfavorite", "Add Tags", "Delete", "Share"]
            )
        }
    }

    func test_whenItemChanges_rebuildsActions() {
        let item = space.buildSavedItem(isFavorite: false, isArchived: true)
        let viewModel = subject(item: item)

        item.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Add Tags", "Delete", "Share"]
        )

        item.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Add Tags", "Delete", "Share"]
        )
    }

    func test_fetchDetailsIfNeeded_whenItemDetailsAreNotAvailable_fetchesItemDetails_andSendsEvent() throws {
        source.stubFetchDetails { _ in }

        let savedItem = space.buildSavedItem()
        savedItem.item?.article = nil
        try space.save()

        let viewModel = subject(item: savedItem)

        let eventSent = expectation(description: "eventSent")
        viewModel.events.sink { event in
            defer { eventSent.fulfill() }

            guard case .contentUpdated = event else {
                XCTFail("Expected contentUpdated event but got \(event)")
                return
            }
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [eventSent], timeout: 2)

        let call = source.fetchDetailsCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.savedItem, savedItem)
    }

    func test_fetchDetailsIfNeeded_whenItemDetailsAreAlreadyAvailable_immediatelySendsContentUpdatedEvent() {
        source.stubFetchDetails { _ in
            XCTFail("Expected no calls to fetch details, but lo, it has been called.")
        }

        let savedItem = space.buildSavedItem(
            item: space.buildItem(article: Article(components: []))
        )

        let viewModel = subject(item: savedItem)
        let contentUpdatedSent = expectation(description: "contentUpdatedSent")
        viewModel.events.sink { event in
            guard case .contentUpdated = event else {
                XCTFail("Expected contentUpdated event but got \(event)")
                return
            }
            contentUpdatedSent.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()

        wait(for: [contentUpdatedSent], timeout: 1)
        XCTAssertNil(source.fetchDetailsCall(at: 0))
    }

    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let viewModel = subject(item: space.buildSavedItem())
        viewModel.invokeAction(title: "Display Settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    func test_favorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: false)
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
        let item = space.buildSavedItem(isFavorite: true)
        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_addTagsAction_sendsAddTagsViewModel() {
        let viewModel = subject(item: space.buildSavedItem(tags: ["tag 1"]))

        let expectAddTags = expectation(description: "expect add tags to present")
        viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            expectAddTags.fulfill()
            XCTAssertEqual(viewModel?.tags, ["tag 1"])
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Add Tags")

        wait(for: [expectAddTags], timeout: 1)
    }

    func test_delete_delegatesToSource_andSendsDeleteEvent() {
        let item = space.buildSavedItem(isFavorite: true)
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

    func test_share_updatesSharedActivity() {
        let viewModel = subject(item: space.buildSavedItem())
        viewModel.invokeAction(title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item = space.buildSavedItem()
        let viewModel = subject(item: item)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL, item.bestURL)
    }

    func test_externalSave_forwardsToSource() {
        source.stubSaveURL { _ in }

        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Save")
        XCTAssertEqual(source.saveURLCall(at: 0)?.url, url)
    }

    func test_externalCopy_copiesToClipboard() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Copy link")
        XCTAssertEqual(pasteboard.url, url)
    }

    func test_externalShare_updatesSharedActivity() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_externalOpen_updatesPresentedWebReaderURL() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Open")
        XCTAssertEqual(viewModel.presentedWebReaderURL, url)
    }

    func test_webActivitiesActions_whenItemIsSaved_canArchive() throws {
        let savedItem = space.buildSavedItem()

        let viewModel = subject(item: savedItem)

        let webActivitiesExpectation = expectation(description: "Web activity list includes archive")
        source.stubFetchItem { url in
            defer { webActivitiesExpectation.fulfill() }
            return savedItem.item
        }

        let webViewActivityList = viewModel.webViewActivityItems(url: savedItem.url!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Archive")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Delete")
        XCTAssertEqual(webViewActivityList[2].activityTitle, "Favorite")

        wait(for: [webActivitiesExpectation], timeout: 1)
    }

    func test_webActivitiesActions_whenItemIsArchive_canMoveToSaves() throws {
        let savedItem = space.buildSavedItem()
        savedItem.isArchived = true
        try space.save()

        let viewModel = subject(item: savedItem)
        let webActivitiesExpectation = expectation(description: "Web activity list includes move to saves")
        source.stubFetchItem { url in
            defer { webActivitiesExpectation.fulfill() }
            return savedItem.item
        }

        let webViewActivityList = viewModel.webViewActivityItems(url: savedItem.url!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Move to Saves")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Delete")
        XCTAssertEqual(webViewActivityList[2].activityTitle, "Favorite")

        wait(for: [webActivitiesExpectation], timeout: 1)
    }
}

extension SavedItemViewModel {
    func invokeAction(title: String) {
        invokeAction(from: _actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
