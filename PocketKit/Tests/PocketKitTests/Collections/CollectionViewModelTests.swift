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
    private var featureFlags: MockFeatureFlagService!
    private var notificationCenter: NotificationCenter!
    private var collectionController: RichFetchedResultsController<CollectionStory>!

    private var subscriptions: Set<AnyCancellable> = []

    @MainActor
    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()
        user = PocketUser(userDefaults: UserDefaults())
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
        featureFlags = MockFeatureFlagService()
        notificationCenter = .default

        userDefaults = UserDefaults(suiteName: "CollectionViewModelTests")
        featureFlags.stubIsAssigned { flag, variant in
            if flag == .nativeCollections {
                return true
            }
            XCTFail("Unknown feature flag")
            return false
        }
        self.collectionController = space.makeCollectionStoriesController(slug: "slug-1")
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "CollectionViewModelTests")
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    @MainActor
    func subject(
        slug: String,
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
            slug: slug,
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

    // MARK: - Collection Actions
    @MainActor
    func test_archive_sendsRequestToSource_andSendsArchiveEvent() throws {
        let item = space.buildSavedItem().item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let expectArchive = expectation(description: "expect source.archive(_:)")
        source.stubArchiveSavedItem { archivedSavedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedSavedItem === item?.savedItem)
        }

        let expectArchiveEvent = expectation(description: "expect archive event")
        viewModel.$events.dropFirst().sink { event in
            guard case .archive = event else {
                XCTFail("Received unexpected event: \(String(describing: event))")
                return
            }

            expectArchiveEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.archive()
        wait(for: [expectArchive, expectArchiveEvent], timeout: 1)
    }

    @MainActor
    func test_moveToSaves_withSavedItem_sendsRequestToSource_AndRefreshes() throws {
        let item = space.buildSavedItem().item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

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

    @MainActor
    func test_moveToSaves_withoutSavedItem_sendsRequestToSource_AndRefreshes() {
        let collection = setupCollection(with: nil)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let expectMoveToSaves = expectation(description: "expect source.url(_:)")
        source.stubSaveURL { url in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertEqual(url, "https://getpocket.com/collections/slug-1")
        }

        viewModel.moveToSaves { _ in }

        wait(for: [expectMoveToSaves], timeout: 1)
    }

    @MainActor
    func test_savedCollection_buildsCorrectActions() throws {
        // not-favorited, not-archived
        let savedItem = space.buildSavedItem(isFavorite: false, isArchived: false)
        let item = savedItem.item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        source.stubFavoriteSavedItem { favoritedSavedItem in
            XCTAssertTrue(favoritedSavedItem.item === item)
            XCTAssertTrue(favoritedSavedItem === item?.savedItem)
            do {
                savedItem.isFavorite = true
                try self.space.save()
            } catch {
                XCTFail("unable to update item")
            }
        }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()
        XCTAssertEqual(
            viewModel.actions.map(\.title),
            ["Favorite", "Add tags", "Delete", "Share"]
        )

        viewModel.invokeAction(title: "Favorite")

        XCTAssertEqual(
            viewModel.actions.map(\.title),
            ["Unfavorite", "Add tags", "Delete", "Share"]
        )
    }

    @MainActor
    func test_favorite_delegatesToSource() throws {
        let item = space.buildSavedItem(isFavorite: false).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let expectFavorite = expectation(description: "expect source.favorite(_:)")

        source.stubFavoriteSavedItem { favoritedSavedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedSavedItem.item === item)
            XCTAssertTrue(favoritedSavedItem === item?.savedItem)
        }

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 1)
    }

    @MainActor
    func test_unfavorite_delegatesToSource() throws {
        let item = space.buildSavedItem(isFavorite: true).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedSavedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedSavedItem.item === item)
            XCTAssertTrue(unfavoritedSavedItem === item?.savedItem)
        }

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    @MainActor
    func test_tagsAction_withNoTags_isAddTags() throws {
        let item = space.buildSavedItem(tags: []).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()
        let hasCorrectTitle = viewModel.actions.contains { $0.title == "Add tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    @MainActor
    func test_tagsAction_withTags_isEditTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()
        let hasCorrectTitle = viewModel.actions.contains { $0.title == "Edit tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    @MainActor
    func test_addTagsAction_sendsAddTagsViewModel() throws {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

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
    func test_delete_delegatesToSource_andSendsDeleteEvent() throws {
        let item = space.buildSavedItem(isFavorite: true).item
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let expectDelete = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { deletedSavedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedSavedItem.item === item)
        }

        let expectDeleteEvent = expectation(description: "expect delete event")
        viewModel.$events.dropFirst().sink { event in
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

    @MainActor
    func test_report_updatesSelectedRecommendationToReport() throws {
        let item = space.buildItem()
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let reportExpectation = expectation(description: "expected item to be reported")
        viewModel.$selectedCollectionItemToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Report")
        wait(for: [reportExpectation], timeout: 1)
    }

    @MainActor
    func test_share_updatesSharedActivity() throws {
        let item = space.buildItem()
        let story = space.buildCollectionStory()
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let shareExpectation = expectation(description: "expected item to be shared")
        viewModel.$sharedActivity.dropFirst().sink { item in
            XCTAssertNotNil(item)
            shareExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Share")

        wait(for: [shareExpectation], timeout: 1)
    }

    // MARK: - Cell Selection
    @MainActor
    func test_select_withSavedItem_andIsArticle_setsReadableViewModel() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem().item
        savedItem?.isArticle = true

        let story = space.buildCollectionStory(item: savedItem)
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let readableExpectation = expectation(description: "expected readable to be called")
        viewModel.$selectedItem.dropFirst().sink { readable in
            guard case .savedItem = readable else {
                XCTFail("Expected savedItem but got \(String(describing: readable))")
                return
            }
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [readableExpectation], timeout: 1)
    }

    @MainActor
    func test_select_withSavedItem_andIsNotArticle_setsWebView() {
        let item = space.buildItem()
        let savedItem = space.buildSavedItem().item
        savedItem?.isArticle = false

        let story = space.buildCollectionStory(item: savedItem)
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [webExpectation], timeout: 1)
    }

    @MainActor
    func test_select_withRecommendation_andIsSyndicated_setsReadableViewModel() {
        let collectionItem = space.buildItem()
        let storyItem = space.buildItem(syndicatedArticle: space.buildSyndicatedArticle())
        let savedItem = space.buildRecommendation(item: storyItem).item

        let story = space.buildCollectionStory(item: savedItem)
        let collection = space.buildCollection(stories: [story], item: collectionItem)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let readableExpectation = expectation(description: "expected readable to be called")
        viewModel.$selectedItem.dropFirst().sink { readable in
            guard case .recommendable = readable else {
                XCTFail("Expected recommendation but got \(String(describing: readable))")
                return
            }
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [readableExpectation], timeout: 1)
    }

    @MainActor
    func test_select_withRecommendation_andIsNotSyndicated_setsWebView() {
        let collectionItem = space.buildItem()
        let storyItem = space.buildItem()
        let savedItem = space.buildRecommendation(item: storyItem).item

        let story = space.buildCollectionStory(item: savedItem)
        let collection = space.buildCollection(stories: [story], item: collectionItem)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [webExpectation], timeout: 1)
    }

    @MainActor
    func test_select_withNotSyndicated_andIsNotSaved_setsWebView() {
        let collectionItem = space.buildItem()
        let storyItem = space.buildItem()
        let story = space.buildCollectionStory(item: storyItem)
        let collection = space.buildCollection(stories: [story], item: collectionItem)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let webExpectation = expectation(description: "expected web view to be called")
        viewModel.$presentedStoryWebReaderURL.dropFirst().sink { url in
            XCTAssertNotNil(url)
            XCTAssertEqual(url?.absoluteString, "story-url")
            webExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [webExpectation], timeout: 1)
    }

    @MainActor
    func test_select_withCollection_showsNativeCollectionView() throws {
        let item = space.buildItem(givenURL: "https://getpocket.com/collections/slug-1")
        let story = space.buildCollectionStory(item: item)
        _ = setupCollection(with: item, space: space, stories: [story])
        try self.space.save()

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubViewObject { _ in
            story
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: "slug-1", source: source)
        viewModel.fetch()

        let readableExpectation = expectation(description: "expected readable to be called")
        viewModel.$selectedItem.dropFirst().sink { readable in
            guard case .collection = readable else {
                XCTFail("Expected collection but got \(String(describing: readable))")
                return
            }
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(cell: .story(viewModel.storyViewModel(for: story)))

        wait(for: [readableExpectation], timeout: 1)
    }

    // MARK: - Story Actions
    @MainActor
    func test_reportAction_forStories_updatesSelectedStoryToReport() throws {
        let item = space.buildItem()
        let story = space.buildCollectionStory(item: item)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: collection.slug)

        let reportExpectation = expectation(description: "expected to update selected story to report")
        viewModel.$selectedStoryToReport.dropFirst().sink { story in
            XCTAssertNotNil(story)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        let storyViewModel = viewModel.storyViewModel(for: story)
        let action = storyViewModel.overflowActions?.first { $0.identifier == .report }
        XCTAssertNotNil(action)
        action?.handler?(nil)

        wait(for: [reportExpectation], timeout: 1)
    }

    @MainActor
    func test_shareAction_forStories_updatesSelectedStoryToShare() throws {
        let item = space.buildItem()
        let story = space.buildCollectionStory(item: item)

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: [story], item: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)

        let reportExpectation = expectation(description: "expected to update selected story to report")
        viewModel.$sharedStoryActivity.dropFirst().sink { story in
            XCTAssertNotNil(story)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        let storyViewModel = viewModel.storyViewModel(for: story)
        let action = storyViewModel.overflowActions?.first { $0.identifier == .shareItem }
        XCTAssertNotNil(action)
        action?.handler?(nil)

        wait(for: [reportExpectation], timeout: 1)
    }

    private func setupCollection(with item: Item?, space: Space? = nil, stories: [CollectionStory] = []) -> Collection {
        let space = space ?? self.space!

        source.stubFetchItem { url in
            return item
        }
        let collection = space.buildCollection(stories: stories, item: item)
        return collection
    }

    @MainActor
    func test_snapshot_whenNetworkIsInitiallyAvailable_hasCorrectSnapshot() {
        let item = space.buildItem()
        let collection = setupCollection(with: item)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        let viewModel = subject(slug: collection.slug)
        XCTAssertNil(viewModel.snapshot.indexOfSection(.error))
    }

    @MainActor
    func test_snapshot_whenNetworkIsUnavailable_andNoLocalData_hasCorrectSnapshot() throws {
        networkPathMonitor.update(status: .unsatisfied)

        let collection = space.buildCollection(slug: "collection-slug", title: "", authors: [], stories: [], item: nil)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: collection.slug, networkPathMonitor: networkPathMonitor)

        let snapshotExpectation = expectation(description: "expect a snapshot")

        viewModel.$snapshot.dropFirst().sink { snapshot in
            XCTAssertNotNil(snapshot.indexOfSection(.error))
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .error), [.error])
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [snapshotExpectation], timeout: 1)
    }

    @MainActor
    func test_snapshot_whenOffline_thenReconnects_hasCorrectSnapshot() async {
        networkPathMonitor.update(status: .unsatisfied)

        let collection = space.buildCollection(slug: "collection-slug", title: "", authors: [], stories: [], item: nil)

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubFetchCollection { _ in }

        let viewModel = subject(slug: collection.slug)

        let loadingExpectation = expectation(description: "expect loading snapshot")
        let errorSnapshotExpectation = expectation(description: "expect error snapshot")
        var count = 0
        viewModel.$snapshot.dropFirst().sink { snapshot in
            count += 1
            if count == 1 {
                XCTAssertNotNil(snapshot.indexOfSection(.error))
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .error), [.error])
                errorSnapshotExpectation.fulfill()
            } else if count == 2 {
                XCTAssertNotNil(snapshot.indexOfSection(.loading))
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .loading), [.loading])
                loadingExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        viewModel.fetch()
        networkPathMonitor.update(status: .satisfied)

        await fulfillment(of: [errorSnapshotExpectation, loadingExpectation], timeout: 1, enforceOrder: true)
    }

    // MARK: - Error Handling
    @MainActor
    func test_snapshot_withFetchingCollectionError_hasCorrectSnapshot() async throws {
        let item = space.buildItem()
        let collection = setupCollection(with: item)

        let errorExpectation = expectation(description: "should throw an error")

        source.stubMakeCollectionStoriesController {
            self.collectionController
        }

        source.stubFetchCollection { _ in
            errorExpectation.fulfill()
            throw CollectionServiceError.nullCollection
        }

        let viewModel = subject(slug: collection.slug)
        let errorSnapshotExpectation = expectation(description: "expect error snapshot")
        let loadingExpectation = expectation(description: "expect loading snapshot")

        var count = 0
        viewModel.$snapshot.sink { snapshot in
            count += 1
            if count == 1 {
                XCTAssertNotNil(snapshot.indexOfSection(.empty))
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .empty), [.empty])
                errorSnapshotExpectation.fulfill()
            } else if count == 2 {
                XCTAssertNotNil(snapshot.indexOfSection(.loading))
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .loading), [.loading])
                loadingExpectation.fulfill()
            } else if count == 3 {
                XCTAssertNotNil(snapshot.indexOfSection(.error))
                XCTAssertEqual(snapshot.itemIdentifiers(inSection: .error), [.error])
            }
        }.store(in: &subscriptions)

        viewModel.fetch()

        await fulfillment(of: [errorExpectation, errorSnapshotExpectation, loadingExpectation], timeout: 1)
    }
}

private extension CollectionViewModel {
    func invokeAction(title: String) {
        invokeAction(from: actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
