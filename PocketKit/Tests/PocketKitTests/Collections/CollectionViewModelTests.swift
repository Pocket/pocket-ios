// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import SharedPocketKit
import Analytics

@testable import PocketKit
@testable import Sync

class CollectionViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var user: User!
    private var subscriptionStore: SubscriptionStore!
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var userDefaults: UserDefaults!
    private var space: Space!
    private var featureFlags: FeatureFlagServiceProtocol!
    private var notificationCenter: NotificationCenter!
    private var collectionController: RichFetchedResultsController<CollectionStory>!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        user = PocketUser(userDefaults: UserDefaults())
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
        featureFlags = MockFeatureFlagService()
        notificationCenter = .default

        userDefaults = UserDefaults(suiteName: "CollectionViewModelTests")
        space = .testSpace()
        self.collectionController = space.makeCollectionStoriesController(slug: "slug")
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "CollectionViewModelTests")
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        collection: Collection,
        source: Source? = nil,
        tracker: Tracker? = nil,
        user: User? = nil,
        store: SubscriptionStore? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil,
        userDefaults: UserDefaults? = nil,
        featureFlags: FeatureFlagServiceProtocol? = nil,
        notificationCenter: NotificationCenter? = nil
    ) -> CollectionViewModel {
        CollectionViewModel(
            collection: collection,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            user: user ?? self.user,
            store: store ?? self.subscriptionStore,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            userDefaults: userDefaults ?? self.userDefaults,
            featureFlags: featureFlags ?? self.featureFlags,
            notificationCenter: notificationCenter ?? self.notificationCenter
        )
    }

    func test_archive_sendsRequestToSource_andSendsArchiveEvent() {
        let item = space.buildSavedItem().item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let expectArchive = expectation(description: "expect source.archive(_:)")
        source.stubArchiveSavedItem { archivedSavedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedSavedItem === item?.savedItem)
        }

        let expectArchiveEvent = expectation(description: "expect archive event")
        viewModel.events.dropFirst().sink { event in
            guard case .archive = event else {
                XCTFail("Received unexpected event: \(String(describing: event))")
                return
            }

            expectArchiveEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.archive()
        wait(for: [expectArchive, expectArchiveEvent], timeout: 1)
    }

    func test_moveToSaves_withSavedItem_sendsRequestToSource_AndRefreshes() {
        let item = space.buildSavedItem().item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let expectMoveToSaves = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { unarchivedSavedItem in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertTrue(unarchivedSavedItem === item?.savedItem)
        }
        source.stubSaveURL { url in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertEqual(url, "https://getpocket.com/collections/slug-1")
        }
        viewModel.moveToSaves { _ in }

        wait(for: [expectMoveToSaves], timeout: 1)
    }

    func test_moveToSaves_withoutSavedItem_sendsRequestToSource_AndRefreshes() {
        let collection = setupCollection(with: nil)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let expectMoveToSaves = expectation(description: "expect source.url(_:)")
        source.stubSaveURL { url in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertEqual(url, "https://getpocket.com/collections/slug-1")
        }

        viewModel.moveToSaves { _ in }

        wait(for: [expectMoveToSaves], timeout: 1)
    }

    func test_savedCollection_buildsCorrectActions() {
        // not-favorited, not-archived
        let item = space.buildSavedItem(isFavorite: false, isArchived: false).item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Favorite", "Add tags", "Delete", "Share"]
        )

        // favorited
        item?.savedItem?.isFavorite = true

        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Unfavorite", "Add tags", "Delete", "Share"]
        )
    }

    func test_favorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: false).item
        let collection = setupCollection(with: item)

        let expectFavorite = expectation(description: "expect source.favorite(_:)")

        source.stubFavoriteSavedItem { favoritedSavedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedSavedItem.item === item)
            XCTAssertTrue(favoritedSavedItem === item?.savedItem)
        }

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)
        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 1)
    }

    func test_unfavorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: true).item
        let collection = setupCollection(with: item)

        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedSavedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedSavedItem.item === item)
            XCTAssertTrue(unfavoritedSavedItem === item?.savedItem)
        }

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_tagsAction_withNoTags_isAddTags() throws {
        let item = space.buildSavedItem(tags: []).item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Add tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_tagsAction_withTags_isEditTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Edit tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_addTagsAction_sendsAddTagsViewModel() {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        source.stubRetrieveTags { _ in return nil }
        source.stubFetchAllTags { return [] }
        let expectAddTags = expectation(description: "expect add tags to present")
        viewModel.$presentedAddTags.dropFirst().sink { viewModel in
            expectAddTags.fulfill()
            XCTAssertEqual(viewModel?.tags, ["tag 1"])
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Edit tags")

        wait(for: [expectAddTags], timeout: 10)
    }

    func test_delete_delegatesToSource_andSendsDeleteEvent() {
        let item = space.buildSavedItem(isFavorite: true).item
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let expectDelete = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { deletedSavedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedSavedItem.item === item)
        }

        let expectDeleteEvent = expectation(description: "expect delete event")
        viewModel.events.dropFirst().sink { event in
            guard case .delete = event else {
                XCTFail("Received unexpected event: \(String(describing: event))")
                return
            }

            expectDeleteEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Delete")
        viewModel.presentedAlert?.actions.first { $0.title == "Yes" }?.invoke()

        wait(for: [expectDelete, expectDeleteEvent], timeout: 1)
    }

    func test_report_updatesSelectedRecommendationToReport() {
        let item = space.buildItem()
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let reportExpectation = expectation(description: "expected item to be reported")
        viewModel.$selectedItemToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Report")
        wait(for: [reportExpectation], timeout: 1)
    }

    func test_share_updatesSharedActivity() throws {
        let item = space.buildItem()
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let shareExpectation = expectation(description: "expected item to be shared")
        viewModel.$sharedActivity.dropFirst().sink { item in
            XCTAssertNotNil(item)
            shareExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Share")

        wait(for: [shareExpectation], timeout: 1)
    }

    // MARK: - Cell Selection
    func test_select_withSavedItem_andIsArticle_setsReadableViewModel() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem().item
        savedItem?.isArticle = true

        let story = space.buildCollectionStory(item: savedItem)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let readableExpectation = expectation(description: "expected readable to be called")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            XCTAssertNotNil(readable)
            XCTAssertTrue(readable is SavedItemViewModel)
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(CollectionStoryViewModel(storyModel: viewModel.createStoryViewModel(with: story))))

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_select_withSavedItem_andIsNotArticle_setsWebView() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem().item
        savedItem?.isArticle = false

        let story = space.buildCollectionStory(item: savedItem)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(CollectionStoryViewModel(storyModel: viewModel.createStoryViewModel(with: story))))

        wait(for: [webExpectation], timeout: 1)
    }

    func test_select_withRecommendation_andIsSyndicated_setsReadableViewModel() {
        let item = space.buildItem(syndicatedArticle: space.buildSyndicatedArticle())
        let savedItem = space.buildRecommendation(item: item).item

        let story = space.buildCollectionStory(item: savedItem)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let readableExpectation = expectation(description: "expected readable to be called")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            XCTAssertNotNil(readable)
            XCTAssertTrue(readable is RecommendationViewModel)
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(CollectionStoryViewModel(storyModel: viewModel.createStoryViewModel(with: story))))

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_select_withRecommendation_andIsNotSyndicated_setsWebView() {
        let item = space.buildItem()
        let savedItem = space.buildRecommendation(item: item).item

        let story = space.buildCollectionStory(item: savedItem)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(CollectionStoryViewModel(storyModel: viewModel.createStoryViewModel(with: story))))

        wait(for: [webExpectation], timeout: 1)
    }

    func test_select_withNotSyndicated_andIsNotSaved_setsWebView() {
        let item = space.buildItem()
        let story = space.buildCollectionStory(item: item)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(collection: collection)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(CollectionStoryViewModel(storyModel: viewModel.createStoryViewModel(with: story))))

        wait(for: [webExpectation], timeout: 1)
    }

    private func setupCollection(with item: Item?) -> Collection {
        let story = space.buildCollectionStory()

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)
        return collection
    }
}

extension CollectionViewModel {
    func invokeAction(title: String) {
        invokeAction(from: _actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
