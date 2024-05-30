// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Analytics
import Combine
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class SavedItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var space: Space!
    private var pasteboard: Pasteboard!
    private var user: User!
    private var subscriptionStore: SubscriptionStore!
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var userDefaults: UserDefaults!
    private var notificationCenter: NotificationCenter!
    private var featureFlagService: MockFeatureFlagService!

    private var subscriptions: Set<AnyCancellable> = []

    @MainActor
    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        pasteboard = MockPasteboard()
        space = .testSpace()
        user = PocketUser(userDefaults: UserDefaults())
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
        userDefaults = .standard
        notificationCenter = .default
        featureFlagService = MockFeatureFlagService()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
        networkPathMonitor = nil
        subscriptionStore = nil
        try super.tearDownWithError()
    }

    @MainActor
    func subject(
        item: SavedItem,
        source: Source? = nil,
        tracker: Tracker? = nil,
        pasteboard: UIPasteboard? = nil,
        user: User? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil,
        notificationCenter: NotificationCenter? = nil,
        featureFlagService: FeatureFlagServiceProtocol? = nil
    ) -> SavedItemViewModel {
        SavedItemViewModel(
            item: item,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            pasteboard: pasteboard ?? self.pasteboard,
            user: user ?? self.user,
            store: subscriptionStore ?? self.subscriptionStore,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            userDefaults: userDefaults ?? self.userDefaults,
            notificationCenter: notificationCenter ?? self.notificationCenter,
            featureFlagService: featureFlagService ?? self.featureFlagService
        )
    }

    @MainActor
    func test_init_buildsCorrectActions() {
        // not-favorited, not-archived
        do {
            let viewModel = subject(item: space.buildSavedItem(isFavorite: false, isArchived: false))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display settings", "Favorite", "Add tags", "Delete", "Share"]
            )
        }

        // favorited, archived
        do {
            let viewModel = subject(item: space.buildSavedItem(isFavorite: true, isArchived: true))
            XCTAssertEqual(
                viewModel._actions.map(\.title),
                ["Display settings", "Unfavorite", "Add tags", "Delete", "Share"]
            )
        }
    }

    @MainActor
    func test_whenItemChanges_rebuildsActions() {
        let item = space.buildSavedItem(isFavorite: false, isArchived: true)
        let viewModel = subject(item: item)

        item.isFavorite = true
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Unfavorite", "Add tags", "Delete", "Share"]
        )

        item.isArchived = false
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Display settings", "Unfavorite", "Add tags", "Delete", "Share"]
        )
    }

    @MainActor
    func test_fetchDetailsIfNeeded_whenItemDetailsAreNotAvailable_fetchesItemDetails_andSendsEvent() throws {
        let savedItem = space.buildSavedItem()
        savedItem.item?.article = nil
        try space.save()

        source.stubFetchDetails { _ in
            savedItem.item?.article = .some(Article(components: [.text(TextComponent(content: "This article has components"))]))
            return true
        }

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

    @MainActor
    func test_fetchDetailsIfNeeded_whenItemDetailsAreNotAvailable_afterFetching_doesNotSendEvent() throws {
        let savedItem = space.buildSavedItem()
        savedItem.item?.article = nil
        try space.save()

        source.stubFetchDetails { _ in
            savedItem.item?.article = nil
            return false
        }

        let viewModel = subject(item: savedItem)

        let eventSent = expectation(description: "eventSent")
        eventSent.isInverted = true
        viewModel.events.sink { event in
            eventSent.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetchDetailsIfNeeded()
        wait(for: [eventSent], timeout: 2)

        let call = source.fetchDetailsCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.savedItem, savedItem)
        XCTAssertEqual(savedItem.item?.hasArticleComponents, false)
        XCTAssertEqual(savedItem.item?.article, nil)
    }

    @MainActor
    func test_fetchDetailsIfNeeded_whenItemDetailsAreAlreadyAvailable_immediatelySendsContentUpdatedEvent() {
        source.stubFetchDetails { _ in
            XCTFail("Expected no calls to fetch details, but lo, it has been called.")
            return false
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

        wait(for: [contentUpdatedSent], timeout: 2)
        XCTAssertNil(source.fetchDetailsCall(at: 0))
    }

    @MainActor
    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let viewModel = subject(item: space.buildSavedItem())
        viewModel.invokeAction(title: "Display settings")

        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    @MainActor
    func test_favorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: false)
        let expectFavorite = expectation(description: "expect source.favorite(_:)")

        source.stubFavoriteSavedItem { favoritedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 2)
    }

    @MainActor
    func test_unfavorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: true)
        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedItem === item)
        }

        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 2)
    }

    @MainActor
    func test_tagsAction_withNoTags_isAddTags() throws {
        let savedItem = space.buildSavedItem(tags: [])
        try space.save()

        let viewModel = subject(item: savedItem)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Add tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    @MainActor
    func test_tagsAction_withTags_isEditTags() throws {
        let savedItem = space.buildSavedItem(tags: ["tag 1"])
        try space.save()

        let viewModel = subject(item: savedItem)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Edit tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    @MainActor
    func test_addTagsAction_sendsAddTagsViewModel() {
        let viewModel = subject(item: space.buildSavedItem(tags: ["tag 1"]))
        source.stubRetrieveTags { _ in return nil }
        source.stubFetchAllTags { return [] }
        let expectAddTags = expectation(description: "expect add tags to present")
        viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            expectAddTags.fulfill()
            XCTAssertEqual(viewModel?.tags, ["tag 1"])
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Edit tags")

        wait(for: [expectAddTags], timeout: 2)
    }

    @MainActor
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

        wait(for: [expectDelete, expectDeleteEvent], timeout: 2)
    }

    @MainActor
    func test_archive_sendsRequestToSource_andSendsArchiveEvent() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem(item: item)
        let viewModel = subject(item: savedItem)

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
        let savedItem = space.buildSavedItem(item: item)

        let expectMoveFromArchiveToSaves = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { item in
            defer { expectMoveFromArchiveToSaves.fulfill() }
            XCTAssertTrue(item === savedItem)
        }

        let viewModel = subject(item: savedItem)
        viewModel.moveFromArchiveToSaves { _ in }

        wait(for: [expectMoveFromArchiveToSaves], timeout: 2)
    }

    @MainActor
    func test_share_updatesSharedActivity() {
        let viewModel = subject(item: space.buildSavedItem())
        viewModel.invokeAction(title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    @MainActor
    func test_showWebReader_updatesPresentedWebReaderURL() {
        let item = space.buildSavedItem()
        let viewModel = subject(item: item)
        viewModel.showWebReader()

        XCTAssertEqual(viewModel.presentedWebReaderURL?.absoluteString, item.bestURL)
    }

    @MainActor
    func test_externalSave_forwardsToSource() {
        source.stubSaveURL { _ in }

        let viewModel = subject(item: space.buildSavedItem())
        let url = "https://getpocket.com"
        let actions = viewModel.externalActions(for: URL(string: url)!)
        viewModel.invokeAction(from: actions, title: "Save")
        XCTAssertEqual(source.saveURLCall(at: 0)?.url, url)
    }

    @MainActor
    func test_externalCopy_copiesToClipboard() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Copy link")
        XCTAssertEqual(pasteboard.url, url)
    }

    @MainActor
    func test_externalShare_updatesSharedActivity() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Share")
        XCTAssertNotNil(viewModel.sharedActivity)
    }

    @MainActor
    func test_externalOpen_updatesPresentedWebReaderURL() {
        let viewModel = subject(item: space.buildSavedItem())
        let url = URL(string: "https://getpocket.com")!
        let actions = viewModel.externalActions(for: url)
        viewModel.invokeAction(from: actions, title: "Open")
        XCTAssertEqual(viewModel.presentedWebReaderURL, url)
    }

    @MainActor
    func test_webActivitiesActions_whenItemIsSaved_canArchive() throws {
        let savedItem = space.buildSavedItem()

        let viewModel = subject(item: savedItem)

        let webActivitiesExpectation = expectation(description: "Web activity list includes archive")
        source.stubFetchItem { url in
            defer { webActivitiesExpectation.fulfill() }
            return savedItem.item
        }

        let webViewActivityList = viewModel.webViewActivityItems(url: URL(string: savedItem.url)!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Archive")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Delete")
        XCTAssertEqual(webViewActivityList[2].activityTitle, "Favorite")

        wait(for: [webActivitiesExpectation], timeout: 2)
    }

    @MainActor
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

        let webViewActivityList = viewModel.webViewActivityItems(url: URL(string: savedItem.url)!)
        XCTAssertEqual(webViewActivityList[0].activityTitle, "Move to Saves")
        XCTAssertEqual(webViewActivityList[1].activityTitle, "Delete")
        XCTAssertEqual(webViewActivityList[2].activityTitle, "Favorite")

        wait(for: [webActivitiesExpectation], timeout: 2)
    }

    @MainActor
    func test_readerProgress() throws {
        let savedItem = space.buildSavedItem()
        try space.save()

        let viewModel = subject(item: savedItem)
        let progress = IndexPath(row: 2, section: 4)
        viewModel.trackReadingProgress(index: progress)

        let savedProgress = viewModel.readingProgress()

        XCTAssertEqual(progress, savedProgress)

        viewModel.deleteReadingProgress()

        let deletedProgress = viewModel.readingProgress()

        XCTAssertNil(deletedProgress)
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
