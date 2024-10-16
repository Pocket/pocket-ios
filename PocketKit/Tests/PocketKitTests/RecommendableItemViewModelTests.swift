// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Analytics
import Combine
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class RecommendableItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!
    private var tracker: MockTracker!
    private var pasteboard: MockPasteboard!
    private var user: User!
    private var userDefaults: UserDefaults!
    private var appSession: AppSession!
    private var mockAuthenticationSession: MockAuthenticationSession!
    private var accessService: PocketAccessService!

    private var subscriptions: Set<AnyCancellable> = []

    @MainActor
    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        pasteboard = MockPasteboard()
        space = .testSpace()
        userDefaults = .standard
        user = PocketUser(userDefaults: userDefaults)

        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.setCurrentSession(SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id"))

        mockAuthenticationSession = MockAuthenticationSession()
        mockAuthenticationSession.stubStart {
            self.mockAuthenticationSession.completionHandler?(
                self.mockAuthenticationSession.url,
                self.mockAuthenticationSession.error
            )
            return true
        }

        let authClient = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token", tracker: tracker) { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }
        accessService = PocketAccessService(
            authorizationClient: authClient,
            appSession: appSession,
            tracker: tracker,
            client: MockV3Client()
        )

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    @MainActor
    func subject(
        recommendation: CDRecommendation,
        source: Source? = nil,
        tracker: Tracker? = nil,
        pasteboard: Pasteboard? = nil,
        user: User? = nil,
        userDefaults: UserDefaults? = nil
    ) -> RecommendableItemViewModel {
        RecommendableItemViewModel(
            item: recommendation.item,
            source: source ?? self.source,
            accessService: accessService,
            tracker: tracker ?? self.tracker,
            pasteboard: pasteboard ?? self.pasteboard,
            user: user ?? self.user,
            userDefaults: userDefaults ?? self.userDefaults
        )
    }

    @MainActor
    func test_init_buildsCorrectActions() throws {
        // not saved
        do {
            let recommendation = space.buildRecommendation(item: space.buildItem())
            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display settings", "Save", "Share", "Report"]
            )
        }

        // not-favorited, not-archived
        do {
            let item = space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2")
            let recommendation = space.buildRecommendation(remoteID: "rec-2", item: item)

            try space.createSavedItem(isFavorite: false, isArchived: false, item: item)

            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display settings", "Favorite", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let item = space.buildItem(remoteID: "item-3", givenURL: "https://example.com/items/item-2")
            let recommendation = space.buildRecommendation(remoteID: "rec-3", item: item)

            try space.createSavedItem(isFavorite: true, isArchived: true, item: item)

            let viewModel = subject(recommendation: recommendation)
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display settings", "Unfavorite", "Delete", "Share"]
            )
        }
    }

    @MainActor
    func test_whenItemChanges_rebuildsActions() throws {
        let item = space.buildItem()
        let recommendation = try space.createRecommendation(item: item)
        let viewModel = subject(recommendation: recommendation)

        let savedItem = try space.createSavedItem(isFavorite: false, isArchived: true, item: item)

        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Favorite", "Delete", "Share"]
        )

        savedItem.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Unfavorite", "Delete", "Share"]
        )

        savedItem.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Unfavorite", "Delete", "Share"]
        )

        item.savedItem = nil
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Save", "Share", "Report"]
        )

        item.savedItem = savedItem
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Unfavorite", "Delete", "Share"]
        )
    }

    @MainActor
    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())
        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Display settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    @MainActor
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

        wait(for: [expectFavorite], timeout: 2)
    }

    @MainActor
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

        wait(for: [expectUnfavorite], timeout: 2)
    }

    @MainActor
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

        wait(for: [expectDelete, expectDeleteEvent], timeout: 2)
    }

    @MainActor
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

        viewModel.archive()
        wait(for: [expectArchive, expectArchiveEvent], timeout: 2)
    }

    @MainActor
    func test_moveFromArchiveToSaves_sendsRequestToSource_AndRefreshes() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(isArchived: true, item: item)
        let recommendation = space.buildRecommendation(item: item)

        let expectMoveFromArchiveToSaves = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { item in
            defer { expectMoveFromArchiveToSaves.fulfill() }
            XCTAssertTrue(item === savedItem)
        }

        let viewModel = subject(recommendation: recommendation)
        viewModel.moveFromArchiveToSaves { _ in }

        wait(for: [expectMoveFromArchiveToSaves], timeout: 2)
    }

    @MainActor
    func test_share_updatesSharedActivity() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)
        viewModel.invokeAction(title: "Share")

        XCTAssertNotNil(viewModel.sharedActivity)
    }

    @MainActor
    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        savedItem.item = item
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL, URL(string: item.bestURL)!)
    }

    @MainActor
    func test_save_delegatesToSource() {
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let expectSave = expectation(description: "expect source.save(_:)")
        source.stubSaveItem { saved in
            defer { expectSave.fulfill() }
            XCTAssertTrue(saved === recommendation.item)
        }

        let viewModel = subject(recommendation: recommendation)

        viewModel.invokeAction(title: "Save")

        wait(for: [expectSave], timeout: 2)
    }

    @MainActor
    func test_report_updatesSelectedRecommendationToReport() {
        let recommendation = space.buildRecommendation(item: space.buildItem())

        let viewModel = subject(recommendation: recommendation)

        let reportExpectation = expectation(description: "expected recommendation to be reported")
        viewModel.$selectedItemToReport.dropFirst().sink { item in
            XCTAssertNotNil(item)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Report")
        wait(for: [reportExpectation], timeout: 2)
    }

    @MainActor
    func test_externalSave_forwardsToSource() throws {
        source.stubSaveURL { _ in }

        let viewModel = try subject(recommendation: space.createRecommendation(item: space.buildItem()))
        let url = "https://getpocket.com"
        let actions = viewModel.externalActions(for: URL(string: url)!)
        viewModel.invokeAction(from: actions, title: "Save")
        XCTAssertEqual(source.saveURLCall(at: 0)?.url, url)
    }

    @MainActor
    func test_externalCopy_copiesToClipboard() throws {
        let viewModel = try subject(recommendation: space.createRecommendation(item: space.buildItem()))
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)

        viewModel.invokeAction(from: actions, title: "Copy link")

        XCTAssertEqual(pasteboard.url, url)
    }

    @MainActor
    func test_externalShare_updatesSharedActivity() throws {
        let viewModel = try subject(recommendation: space.createRecommendation(item: space.buildItem()))
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    @MainActor
    func test_externalOpen_updatesPresentedWebReaderURL() throws {
        let viewModel = try subject(recommendation: space.createRecommendation(item: space.buildItem()))
        let url = URL(string: "https://example.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Open")
        XCTAssertEqual(viewModel.presentedWebReaderURL, url)
    }

    @MainActor
    func test_fetchDetailsIfNeeded_whenMarticleIsNil_fetchesDetailsForRecommendation() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem()
        )
        source.stubFetchDetailsForItem { item in
            item.article = .some(Article(components: [.text(TextComponent(content: "This article has components"))]))
            return true
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
        wait(for: [receivedEvent], timeout: 2)
        XCTAssertNotNil(recommendation.item.article)
    }

    @MainActor
    func test_fetchDetailsIfNeeded_whenMarticleIsNilAfterFetching_returnsWebView() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem()
        )
        source.stubFetchDetailsForItem { item in
            item.article = nil
            return false
        }

        let viewModel = subject(recommendation: recommendation)
        let receivedEvent = expectation(description: "receivedEvent")
        receivedEvent.isInverted = true
        viewModel.events.sink { event in
            receivedEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [receivedEvent], timeout: 2)

        XCTAssertFalse(recommendation.item.hasArticleComponents)
        XCTAssertNil(recommendation.item.article)
    }

    @MainActor
    func test_fetchDetailsIfNeeded_whenMarticleIsPresent_immediatelySendsContentUpdatedEvent() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem(article: .init(components: []))
        )

        source.stubFetchDetailsForItem { rec in
            XCTFail("Should not fetch details when article content is already available")
            return false
        }

        let viewModel = subject(recommendation: recommendation)
        let receivedEvent = expectation(description: "receivedEvent")
        viewModel.events.sink { event in
            receivedEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [receivedEvent], timeout: 2)
    }

    @MainActor
    func test_webActivitiesActions_whenRecommendation_notSaved() {
        let recommendation = space.buildRecommendation(
            item: space.buildItem()
        )

        let viewModel = subject(recommendation: recommendation)

        let webActivitiesExpectation = expectation(description: "Recommendation Web Activities")
        source.stubFetchItem { url in
            defer { webActivitiesExpectation.fulfill() }
            return recommendation.item
        }

        let webViewActivityList = viewModel.webViewActivityItems(url: URL(string: recommendation.item.givenURL)!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Save")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Report")

        wait(for: [webActivitiesExpectation], timeout: 2)
    }

    @MainActor
    func test_webActivitiesActions_whenRecommendation_isSaved() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(
            item: item
        )
        try space.createSavedItem(isFavorite: false, isArchived: false, item: item)

        let viewModel = subject(recommendation: recommendation)

        let webActivitiesExpectation = expectation(description: "Recommendation Web Activities")
        source.stubFetchItem { url in
            defer { webActivitiesExpectation.fulfill() }
            return recommendation.item
        }

        let webViewActivityList = viewModel.webViewActivityItems(url: URL(string: recommendation.item.givenURL)!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Archive")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Delete")
        XCTAssertEqual(webViewActivityList[2].activityTitle, "Favorite")

        wait(for: [webActivitiesExpectation], timeout: 2)
    }

    @MainActor
    func test_readerProgress() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(
            item: item
        )

        try space.save()

        let viewModel = subject(recommendation: recommendation)
        let progress = IndexPath(row: 2, section: 4)
        viewModel.trackReadingProgress(index: progress)

        let savedProgress = viewModel.readingProgress()

        XCTAssertEqual(progress, savedProgress)

        viewModel.deleteReadingProgress()

        let deletedProgress = viewModel.readingProgress()

        XCTAssertNil(deletedProgress)
    }
}

extension RecommendableItemViewModel {
    func invokeAction(title: String) {
        invokeAction(from: _actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
