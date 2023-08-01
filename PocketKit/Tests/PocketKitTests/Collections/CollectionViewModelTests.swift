// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import SharedPocketKit

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
    private var collectionController: RichFetchedResultsController<CollectionStory>!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        user = PocketUser(userDefaults: UserDefaults())
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
        userDefaults = UserDefaults(suiteName: "CollectionViewModelTests")
        space = .testSpace()
        self.collectionController = space.makeCollectionStoriesController(slug: "slug")
        source.stubMakeCollectionStoriesController {
            self.collectionController
        }
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "CollectionViewModelTests")
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        slug: String,
        source: Source? = nil
    ) -> CollectionViewModel {
        CollectionViewModel(
            collection: space.buildCollection(),
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            user: user ?? self.user,
            store: subscriptionStore ?? self.subscriptionStore,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            userDefaults: userDefaults ?? self.userDefaults
        )
    }

    func test_archive_sendsRequestToSource_andSendsArchiveEvent() {
        let item = space.buildSavedItem().item
        let collection = setupCollection(with: item)
        let viewModel = subject(slug: collection.slug)

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
        let viewModel = subject(slug: collection.slug)

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
        let viewModel = subject(slug: collection.slug)

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

        let viewModel = subject(slug: collection.slug)
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

        let viewModel = subject(slug: collection.slug)
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

        let viewModel = subject(slug: collection.slug)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_tagsAction_withNoTags_isAddTags() throws {
        let item = space.buildSavedItem(tags: []).item
        let collection = setupCollection(with: item)

        let viewModel = subject(slug: collection.slug)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Add tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_tagsAction_withTags_isEditTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let collection = setupCollection(with: item)

        let viewModel = subject(slug: collection.slug)
        let hasCorrectTitle = viewModel._actions.contains { $0.title == "Edit tags" }
        XCTAssertTrue(hasCorrectTitle)
    }

    func test_addTagsAction_sendsAddTagsViewModel() {
        let item = space.buildSavedItem(tags: ["tag 1"]).item
        let collection = setupCollection(with: item)
        let viewModel = subject(slug: collection.slug)

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
        let viewModel = subject(slug: collection.slug)

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
        let viewModel = subject(slug: collection.slug)

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
        let viewModel = subject(slug: collection.slug)

        let shareExpectation = expectation(description: "expected item to be shared")
        viewModel.$sharedActivity.dropFirst().sink { item in
            XCTAssertNotNil(item)
            shareExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Share")

        wait(for: [shareExpectation], timeout: 1)
    }

    private func setupCollection(with item: Item?) -> Collection {
        let story = space.buildCollectionStory(item: item)

        source.stubFetchItem { url in
            return item
        }

        return space.buildCollection(stories: [story])
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
