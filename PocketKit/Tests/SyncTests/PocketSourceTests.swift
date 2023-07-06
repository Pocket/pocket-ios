// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Apollo
import PocketGraph
import Combine
import SharedPocketKit

@testable import Sync

// swiftlint:disable force_try
class PocketSourceTests: XCTestCase {
    var space: Space!
    var user: MockUser!
    var apollo: MockApolloClient!
    var operations: MockOperationFactory!
    var lastRefresh: MockLastRefresh!
    var slateService: MockSlateService!
    var networkMonitor: MockNetworkPathMonitor!
    var sessionProvider: MockSessionProvider!
    var backgroundTaskManager: MockBackgroundTaskManager!
    var osNotificationCenter: OSNotificationCenter!
    var subscriptions: [AnyCancellable]!
    var userService: MockUserService!
    var featureFlagService: MockFeatureFlagService!

    override func setUp() {
        super.setUp()
        space = .testSpace()
        user = MockUser()
        user.stubStandardSetStatus()
        apollo = MockApolloClient()
        operations = MockOperationFactory()
        lastRefresh = MockLastRefresh()
        slateService = MockSlateService()
        networkMonitor = MockNetworkPathMonitor()
        sessionProvider = MockSessionProvider(session: nil)
        backgroundTaskManager = MockBackgroundTaskManager()
        osNotificationCenter = OSNotificationCenter(notifications: CFNotificationCenterGetDarwinNotifyCenter())
        subscriptions = []
        userService = MockUserService()
        featureFlagService = MockFeatureFlagService()

        lastRefresh.stubGetLastRefreshSaves { nil }
        lastRefresh.stubGetLastRefreshArchive { nil }

        backgroundTaskManager.stubBeginTask { _, _ in return 0 }
        backgroundTaskManager.stubEndTask { _ in }
    }

    override func tearDownWithError() throws {
        try space.clear()
        subscriptions = []
        osNotificationCenter.removeAllObservers()
        try super.tearDownWithError()
    }

    func subject(
        space: Space? = nil,
        user: User? = nil,
        apollo: ApolloClientProtocol? = nil,
        operations: OperationFactory? = nil,
        lastRefresh: LastRefresh? = nil,
        slateService: SlateService? = nil,
        networkMonitor: NetworkPathMonitor? = nil,
        sessionProvider: SessionProvider? = nil,
        osNotificationCenter: OSNotificationCenter? = nil,
        userService: UserService? = nil,
        featureFlagService: FeatureFlagLoadingService? = nil
    ) -> PocketSource {
        PocketSource(
            space: space ?? self.space,
            user: user ?? self.user,
            apollo: apollo ?? self.apollo,
            operations: operations ?? self.operations,
            lastRefresh: lastRefresh ?? self.lastRefresh,
            slateService: slateService ?? self.slateService,
            featureFlagService: featureFlagService ?? self.featureFlagService,
            networkMonitor: networkMonitor ?? self.networkMonitor,
            sessionProvider: sessionProvider ?? self.sessionProvider,
            backgroundTaskManager: backgroundTaskManager ?? self.backgroundTaskManager,
            osNotificationCenter: osNotificationCenter ?? self.osNotificationCenter,
            userService: userService ?? self.userService
        )
    }

    func test_fetching_from_different_threads() async {
        sessionProvider.session = MockSession()

        operations.stubFetchSaves { _, _, _, _  in
            TestSyncOperation { }
        }

        operations.stubFetchArchive { _, _, _, _  in
            TestSyncOperation { }
        }

        let source = subject()

        let expectationToFetchSaves = expectation(description: "Fetch Saves")
        let expectationToFetchArchive = expectation(description: "Fetch Archive")

        Task {
            source.refreshSaves {
                expectationToFetchSaves.fulfill()
            }
        }
        Task {
            source.refreshArchive {
                expectationToFetchArchive.fulfill()
            }
        }

        await fulfillment(of: [expectationToFetchSaves, expectationToFetchArchive], timeout: 10)
    }

    func test_refresh_addsFetchSavesOperationToQueue() {
        let session = MockSession()
        sessionProvider.session = session
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubFetchSaves { _, _, _, _ in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()

        source.refreshSaves()
        waitForExpectations(timeout: 1)
    }

    func test_refreshWithCompletion_callsCompletionWhenFinished() {
        sessionProvider.session = MockSession()
        operations.stubFetchSaves { _, _, _, _  in
            TestSyncOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refreshSaves {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_refresh_whenTokenIsNil_callsCompletion() {
        sessionProvider.session = nil
        operations.stubFetchSaves { _, _, _, _  in
            TestSyncOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refreshSaves {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_favorite_togglesIsFavorite_andExecutesFavoriteMutation() throws {
        let item = try space.createSavedItem(remoteID: "test-item-id")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.favorite(item: item)

        XCTAssertTrue(item.isFavorite)
        waitForExpectations(timeout: 1)
    }

    func test_unfavorite_unsetsIsFavorite_andExecutesUnfavoriteMutation() throws {
        let item = try space.createSavedItem()
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: UnfavoriteItemMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.unfavorite(item: item)

        XCTAssertFalse(item.isFavorite)
        waitForExpectations(timeout: 1)
    }

    func test_delete_removesItemFromLocalStorage_andExecutesDeleteMutation() throws {
        let item = try space.createSavedItem(remoteID: "delete-me", url: "https://mozilla.com/delete")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.delete(item: item)

        let fetchedItem = try space.fetchSavedItem(byURL: "https://mozilla.com/delete")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.hasChanges)
        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_delete_ifSavedItemItemHasRecommendation_doesNotDeleteSavedItemItem() throws {
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.createSavedItem(item: space.buildItem())
        let item = savedItem.item!
        item.recommendation = space.buildRecommendation(item: item)

        let remoteItemURL = item.givenURL

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byURL: remoteItemURL)
        XCTAssertNotNil(fetchedItem)
    }

    func test_delete_ifSavedItemItemHasNoRecommendation_doesNotDeleteSavedItemItem() throws {
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.createSavedItem(item: space.buildItem())
        let item = savedItem.item!

        let remoteItemURL = item.givenURL

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byURL: remoteItemURL)
        XCTAssertNil(fetchedItem)
    }

    func test_archive_archivesLocally_andExecutesArchiveMutation_andUpdatesArchivedAt() throws {
        let item = try space.createSavedItem(remoteID: "archive-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.archive(item: item)

        XCTAssertTrue(item.isArchived)
        XCTAssertFalse(item.hasChanges)
        XCTAssertNotNil(item.archivedAt)
        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_unarchive_executesSaveItemMutation_andUpdatesCreatedAtField() throws {
        let item = try space.createSavedItem(remoteID: "unarchive-me", url: "https://mozilla.com/unarchive")
        item.isArchived = true

        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.unarchive(item: item)

        XCTAssertFalse(item.isArchived)
        XCTAssertNotNil(item.createdAt)
        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_fetchSlateLineup_forwardsToSlateService() async throws {
        slateService.stubFetchSlateLineup { _ in }

        let source = subject()
        try await source.fetchSlateLineup("slate-lineup-identifier")
        XCTAssertEqual(slateService.fetchSlateLineupCall(at: 0)?.identifier, "slate-lineup-identifier")
    }

    func test_savesController_returnsAFetchedResultsController() throws {
        let source = subject()
        let item1 = try space.createSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(1)), item: space.buildItem(title: "Item 1"))
        try space.save()

        let savesResultsController = source.makeSavesController()
        try savesResultsController.performFetch()
        XCTAssertEqual(savesResultsController.fetchedObjects?.compactMap({ $0.objectID }), [item1.objectID])

        let expectationForUpdatedItems = expectation(description: "updated items")
        let delegate = TestSavedItemsControllerDelegate {
            expectationForUpdatedItems.fulfill()
        }
        savesResultsController.delegate = delegate

        let item2 = try space.createSavedItem(
            remoteID: "saved-item-2",
            url: "http://example.com/item-2",
            createdAt: .init(timeIntervalSince1970: TimeInterval(0)),
            item: space.buildItem(
                remoteID: "item-2",
                title: "Item 2",
                givenURL: "https://example.com/items/item-2"
            )
        )
        try space.save()
        try savesResultsController.performFetch()

        wait(for: [expectationForUpdatedItems], timeout: 10)
        XCTAssertEqual(savesResultsController.fetchedObjects?.compactMap({ $0.objectID }), [item1.objectID, item2.objectID])
    }

    func test_resolveUnresolvedSavedItems_enqueuesSaveItemOperation() throws {
        let operationStarted = expectation(description: "operationStarted")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                operationStarted.fulfill()
            }
        }

        let source = subject()

        let savedItem = try! space.createSavedItem()
        let unresolved: UnresolvedSavedItem = UnresolvedSavedItem(context: space.backgroundContext)
        unresolved.savedItem = savedItem
        try space.save()

        source.resolveUnresolvedSavedItems(completion: nil)

        wait(for: [operationStarted], timeout: 10)
        try XCTAssertEqual(space.fetchUnresolvedSavedItems(), [])
    }

    func test_saveRecommendation_createsPendingItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = space.buildItem(givenURL: "https://getpocket.com")
        let recommendation = space.buildRecommendation(item: seededItem)
        try? space.save()

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 10)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.url, "https://getpocket.com")

        XCTAssertEqual(savedItem.item, seededItem)
    }

    func test_saveRecommendation_withArchivedItem_unarchivesItem_andExecutesUnarchiveOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = space.buildItem(givenURL: "https://example.com/item-rec")
        let seededSavedItem = space.buildSavedItem(url: "https://example.com/item-rec", isArchived: true, item: seededItem)
        let recommendation = space.buildRecommendation(item: seededItem)
        try? space.save()

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 10)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.objectID, seededSavedItem.objectID)
        XCTAssertEqual(savedItem.item?.objectID, seededItem.objectID)
        XCTAssertFalse(savedItem.isArchived)
    }

    func test_archiveRecommendation_createsPendingItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = space.buildItem()
        seededItem.savedItem = space.buildSavedItem()
        let recommendation = space.buildRecommendation(item: seededItem)

        let source = subject()
        source.archive(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 10)

        let archivedItems = try space.fetchArchivedItems()
        XCTAssertEqual(archivedItems.count, 1)

        let archivedItem = archivedItems[0]
        XCTAssertEqual(archivedItem.item, seededItem)
        XCTAssertFalse(archivedItem.hasChanges)
        XCTAssertNotNil(archivedItem.archivedAt)
    }

    func test_removeRecommendation_removesRecommendationFromSpace() throws {
        let recommendation1 = space.buildRecommendation(item: space.buildItem())
        let recommendation2 = space.buildRecommendation(item: space.buildItem())

        let source = subject()
        source.remove(recommendation: recommendation1)

        let fetched = try space.fetchRecommendations()
        XCTAssertEqual(fetched, [recommendation2])
    }

    @MainActor
    func test_fetchOfflineContent_fetchesOfflineContent() async throws {
        apollo.stubFetch(
            toReturnFixtureNamed: "single-item-details",
            asResultType: SavedItemByIDQuery.self
        )

        let savedItem = try space.createSavedItem(remoteID: "a-saved-item")
        try space.save()

        let source = subject()
        try await source.fetchDetails(for: savedItem)

        space.backgroundRefresh(savedItem, mergeChanges: true)
        XCTAssertNotNil(savedItem.item)
        XCTAssertFalse(savedItem.hasChanges)
    }

    @MainActor
    func test_fetchDetailsForRecommendation_fetchesOfflineContent() async throws {
        let recommendation = try space.createRecommendation(
            item: space.buildItem(remoteID: "remote-item-id")
        )

        apollo.stubFetch(
            toReturnFixtureNamed: "recommendation-detail",
            asResultType: ItemByIDQuery.self
        )

        let source = subject()
        try await source.fetchDetails(for: recommendation)

        space.backgroundRefresh(recommendation, mergeChanges: true)
        XCTAssertNotNil(recommendation.item.article)
        XCTAssertFalse(recommendation.hasChanges)
    }

    func test_saveURL_insertsSavedItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = "https://getpocket.com"

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 10)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.first?.url, url)
    }

    func test_saveURL_withExistingSavedItem_updatesSavedItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = "https://getpocket.com"
        let seed = space.buildSavedItem(url: url)
        let seedDate = Date()
        seed.createdAt = seedDate
        try? space.save()

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 10)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)
        XCTAssertEqual(savedItems[0].url, url)
        XCTAssertGreaterThan(savedItems[0].createdAt, seedDate)
    }

    func test_saveURL_withArchivedSavedItem_unarchivesItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = "https://getpocket.com"
        _ = space.buildSavedItem(url: "https://getpocket.com", isArchived: true)
        try? space.save()

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 10)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)
        XCTAssertFalse(savedItems[0].isArchived)
    }
}

// MARK: Tags
extension PocketSourceTests {
    func test_addTagsToSavedItem_executesReplaceSavedItemTagsMutation() throws {
        let items = createItemsWithTags(1)
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemAnyMutationOperation { (_, _, _) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.addTags(item: items[0], tags: ["tag 2", "tag 3"])
        XCTAssertEqual(items[0].tags?.count, 2)
        XCTAssertEqual((items[0].tags?[0] as? Tag)?.name, "tag 2")
        XCTAssertEqual((items[0].tags?[1] as? Tag)?.name, "tag 3")
        waitForExpectations(timeout: 1)
    }

    func test_addTagsToSavedItem_withNoTags_executesUpdateSavedItemRemoveTagsMutation() throws {
        let items = createItemsWithTags(1)
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemAnyMutationOperation { (_, _, _) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.addTags(item: items[0], tags: [])
        XCTAssertEqual(items[0].tags?.count, 0)
        waitForExpectations(timeout: 1)
    }

    func test_retrieveTags_excludesTagsAlreadySelected() throws {
        _ = createItemsWithTags(3)
        let source = subject()
        let tags = source.retrieveTags(excluding: ["tag 1", "tag 2"])
        XCTAssertEqual(tags?.count, 1)
        XCTAssertEqual(tags?[0].name, "tag 3")
    }

    func test_filterTags_showsFilteredTags() throws {
        _ = createItemsWithTags(3)
        let source = subject()
        guard let tags = source.filterTags(with: "t", excluding: ["tag 2"]) else {
            XCTFail("Should not be nil")
            return
        }
        XCTAssertEqual(tags.count, 2)
        XCTAssertTrue(tags.compactMap { $0.name }.contains("tag 1"))
        XCTAssertTrue(tags.compactMap { $0.name }.contains("tag 3"))
    }

    func test_deleteTags_executesDeleteTagMutation() throws {
        let items = createItemsWithTags(1)
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: DeleteTagMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }
        try XCTAssertEqual( space.fetchAllTags().compactMap { $0.name }, ["tag 1"])
        let source = subject()
        guard let tag = items[0].tags?[0] as? Tag else {
            XCTFail("Should not be nil")
            return
        }
        source.deleteTag(tag: tag)

        try XCTAssertEqual(space.fetchAllTags(), [])
        wait(for: [expectationToRunOperation], timeout: 10)
    }

    func test_renameTag_executesUpdateTagMutation() throws {
        let tag1: Tag = Tag(context: space.backgroundContext)
        tag1.remoteID = "id 1"
        tag1.name = "tag 1"
        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: TagUpdateMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }
        try XCTAssertEqual( space.fetchAllTags().compactMap { $0.name }, ["tag 1"])

        source.renameTag(from: tag1, to: "tag 3")

        try XCTAssertEqual(space.fetchAllTags().compactMap { $0.name }, ["tag 3"])
        wait(for: [expectationToRunOperation], timeout: 10)
    }

    private func createItemsWithTags(_ number: Int, isArchived: Bool = false) -> [SavedItem] {
        guard number > 0 else { return [] }
        return (1...number).compactMap { num in
            let tag: Tag = Tag(context: space.backgroundContext)
            tag.remoteID = "id \(num)"
            tag.name = "tag \(num)"
            return space.buildSavedItem(remoteID: "saved-item-\(num)", url: "http://example.com/item-\(num)", isArchived: isArchived, tags: [tag])
        }
    }
}

// MARK: - Search Term
extension PocketSourceTests {
    func test_savesSearches_withFreeUser_showSearchResults_searchTitle() throws {
        user.setPremiumStatus(false)

        try setupLocalSavesSearch()
        let source = subject()
        let results = source.searchSaves(search: "saved")
        XCTAssertEqual(results?.count, 2)

        let noResults = source.searchSaves(search: "none")
        XCTAssertEqual(noResults?.isEmpty, true)
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchTitle() throws {
        user.setPremiumStatus(true)
        try setupLocalSavesSearch()
        let source = subject()
        let results = source.searchSaves(search: "saved")
        XCTAssertEqual(results?.count, 2)

        let noResults = source.searchSaves(search: "none")
        XCTAssertEqual(noResults?.isEmpty, true)
    }

    func test_savesSearches_withFreeUser_showSearchResults_searchUrl() throws {
        user.setPremiumStatus(false)
        let urlString = "testUrl.saved"
        try setupLocalSavesSearch(with: urlString)

        let source = subject()
        let results = source.searchSaves(search: "saved")
        XCTAssertEqual(results?.count, 2)

        let noResults = source.searchSaves(search: "none")
        XCTAssertEqual(noResults?.isEmpty, true)
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchUrl() throws {
        user.setPremiumStatus(true)

        let urlString = "testUrl.saved"
        try setupLocalSavesSearch(with: urlString)

        let source = subject()
        let results = source.searchSaves(search: "saved")
        XCTAssertEqual(results?.count, 2)

        let noResults = source.searchSaves(search: "none")
        XCTAssertEqual(noResults?.isEmpty, true)
    }

    func test_savesSearches_withFreeUser_showSearchResults_doesNotSearchTag() throws {
        user.setPremiumStatus(false)

         _ = createItemsWithTags(2)

        try space.save()

        let source = subject()
        let results = source.searchSaves(search: "tag")
        XCTAssertEqual(results?.isEmpty, true)

        let noResults = source.searchSaves(search: "test-tag")
        XCTAssertEqual(noResults?.isEmpty, true)
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchTag() throws {
        user.setPremiumStatus(true)

        _ = createItemsWithTags(2)

        try space.save()

        let source = subject()
        let results = source.searchSaves(search: "tag")
        XCTAssertEqual(results?.count, 2)

        let noResults = source.searchSaves(search: "test-tag")
        XCTAssertEqual(noResults?.count, 0)
    }

    func test_fetchOrCreateSavedItem_retrievesItem() throws {
        let itemParts = SavedItemParts(
            url: "http://localhost:8080/hello",
            remoteID: "saved-item",
            isArchived: false,
            isFavorite: false,
            _createdAt: 1,
            item: SavedItemParts.Item.AsItem(
                remoteID: "item-1",
                givenUrl: "http://localhost:8080/hello",
                title: "item-title"
            ).asRootEntityType
        )

        let source = subject()
        let savedItem = source.fetchOrCreateSavedItem(with: "http://localhost:8080/hello", and: itemParts)

        XCTAssertEqual(savedItem?.remoteID, "saved-item")
        XCTAssertEqual(savedItem?.item?.title, "item-title")
        XCTAssertEqual(savedItem?.item?.bestURL, "http://localhost:8080/hello")
    }

    private func setupLocalSavesSearch(with urlString: String? = nil) throws {
        var url: String?
        _ = (1...2).map {
            if let urlString {
                url = urlString + "-\($0)"
            }
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                url: "http://example.com/item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(remoteID: "saved-item-\($0)", title: "saved-item-\($0)", givenURL: url, num: $0)
            )
        }
        try space.save()
    }
}
// swiftlint:enable force_try
