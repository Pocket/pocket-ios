import XCTest
import Sync
import Analytics
import Combine

@testable import Sync
@testable import PocketKit

class RecommendationViewModelTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!
    private var tracker: MockTracker!
    private var pasteboard: MockPasteboard!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        pasteboard = MockPasteboard()
        space = .testSpace()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        recommendation: Recommendation,
        source: Source? = nil,
        tracker: Tracker? = nil,
        pasteboard: Pasteboard? = nil
    ) -> RecommendationViewModel {
        RecommendationViewModel(
            recommendation: recommendation,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            pasteboard: pasteboard ?? self.pasteboard
        )
    }

    func test_init_buildsCorrectActions() throws {
        // not saved
        do {
            let recommendation = space.buildRecommendation(item: space.buildItem())
            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Save", "Share", "Report"]
            )
        }

        // not-favorited, not-archived
        do {
            let item = space.buildItem()
            let recommendation = space.buildRecommendation(item: item)
            try space.createSavedItem(isFavorite: false, isArchived: false, item: item)

            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Favorite", "Archive", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let item = space.buildItem()
            let recommendation = space.buildRecommendation(item: item)
            try space.createSavedItem(isFavorite: true, isArchived: true, item: item)

            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display Settings", "Unfavorite", "Move to Saves", "Delete", "Share"]
            )
        }
    }

    func test_whenItemChanges_rebuildsActions() throws {
        let item = space.buildItem()
        let recommendation = try space.createRecommendation(item: item)
        let viewModel = subject(recommendation: recommendation)

        let savedItem = try space.createSavedItem(isFavorite: false, isArchived: true, item: item)

        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Favorite", "Move to Saves", "Delete", "Share"]
        )

        savedItem.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Move to Saves", "Delete", "Share"]
        )

        savedItem.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Archive", "Delete", "Share"]
        )

        item.savedItem = nil
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Save", "Share", "Report"]
        )

        item.savedItem = savedItem
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display Settings", "Unfavorite", "Archive", "Delete", "Share"]
        )
    }

    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())
        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Display Settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    func test_favorite_delegatesToSource() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(isFavorite: false, item: item)
        let recommendation = space.buildRecommendation(item: item)

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
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(isFavorite: true, item: item)
        let recommendation = space.buildRecommendation(item: item)

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
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
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
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
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
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(isArchived: true, item: item)
        let recommendation = space.buildRecommendation(item: item)

        let expectUnarchive = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { unarchivedItem in
            defer { expectUnarchive.fulfill() }
            XCTAssertTrue(unarchivedItem === savedItem)
        }

        let viewModel = subject(recommendation: recommendation)
        viewModel.invokeAction(title: "Move to Saves")

        wait(for: [expectUnarchive], timeout: 1)
    }

    func test_share_updatesSharedActivity() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)
        viewModel.invokeAction(title: "Share")

        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL, item.bestURL)
    }

    func test_save_delegatesToSource() {
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let expectSave = expectation(description: "expect source.save(_:)")
        source.stubSaveRecommendation { saved in
            defer { expectSave.fulfill() }
            XCTAssertTrue(saved === recommendation)
        }

        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Save")

        wait(for: [expectSave], timeout: 1)
    }

    func test_report_updatesSelectedRecommendationToReport() {
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)

        let reportExpectation = expectation(description: "expected recommendation to be reported")
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Report")
        wait(for: [reportExpectation], timeout: 1)
    }

    func test_externalSave_forwardsToSource() throws {
        source.stubSaveURL { _ in }

        let viewModel = try subject(recommendation: space.createRecommendation())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Save")
        XCTAssertEqual(source.saveURLCall(at: 0)?.url, url)
    }

    func test_externalCopy_copiesToClipboard() throws {
        let viewModel = try subject(recommendation: space.createRecommendation())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Copy link")

        XCTAssertEqual(pasteboard.url, url)
    }

    func test_externalShare_updatesSharedActivity() throws {
        let viewModel = try subject(recommendation: space.createRecommendation())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_externalOpen_updatesPresentedWebReaderURL() throws {
        let viewModel = try subject(recommendation: space.createRecommendation())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Open")
        XCTAssertEqual(viewModel.presentedWebReaderURL, url)
    }

    func test_fetchDetailsIfNeeded_whenMarticleIsNil_fetchesDetailsForRecommendation() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem()
        )
        source.stubFetchDetailsForRecommendation { rec in
            rec.item?.article = .some(Article(components: []))
        }

        let viewModel = subject(recommendation: recommendation)
        let receivedEvent = expectation(description: "receivedEvent")
        viewModel.events.sink { event in
            defer { receivedEvent.fulfill() }
            guard case .contentUpdated = event else {
                XCTFail("Expected .contentUpdated event but received \(event)")
                return
            }
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [receivedEvent], timeout: 1)
        XCTAssertNotNil(recommendation.item?.article)
    }

    func test_fetchDetailsIfNeeded_whenMarticleIsPresent_immediatelySendsContentUpdatedEvent() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem(article: .init(components: []))
        )

        source.stubFetchDetailsForRecommendation { rec in
            XCTFail("Should not fetch details when article content is already available")
        }

        let viewModel = subject(recommendation: recommendation)
        let receivedEvent = expectation(description: "receivedEvent")
        viewModel.events.sink { event in
            receivedEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [receivedEvent], timeout: 1)
    }
}

extension RecommendationViewModel {
    func invokeAction(title: String) {
        invokeAction(from: _actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
