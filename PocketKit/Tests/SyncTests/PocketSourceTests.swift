// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Apollo
import PocketGraph
import Combine

@testable import Sync

class PocketSourceTests: XCTestCase {
    var space: Space!
    var apollo: MockApolloClient!
    var operations: MockOperationFactory!
    var lastRefresh: MockLastRefresh!
    var slateService: MockSlateService!
    var networkMonitor: MockNetworkPathMonitor!
    var sessionProvider: MockSessionProvider!
    var backgroundTaskManager: MockBackgroundTaskManager!
    var osNotificationCenter: OSNotificationCenter!
    var subscriptions: [AnyCancellable]!

    override func setUpWithError() throws {
        space = .testSpace()
        apollo = MockApolloClient()
        operations = MockOperationFactory()
        lastRefresh = MockLastRefresh()
        slateService = MockSlateService()
        networkMonitor = MockNetworkPathMonitor()
        sessionProvider = MockSessionProvider(session: nil)
        backgroundTaskManager = MockBackgroundTaskManager()
        osNotificationCenter = OSNotificationCenter(notifications: CFNotificationCenterGetDarwinNotifyCenter())
        subscriptions = []

        lastRefresh.stubGetLastRefresh { nil }

        backgroundTaskManager.stubBeginTask { _, _ in return 0 }
        backgroundTaskManager.stubEndTask { _ in }
    }

    override func tearDownWithError() throws {
        try space.clear()
        subscriptions = []
        osNotificationCenter.removeAllObservers()
    }

    func subject(
        space: Space? = nil,
        apollo: ApolloClientProtocol? = nil,
        operations: OperationFactory? = nil,
        lastRefresh: LastRefresh? = nil,
        slateService: SlateService? = nil,
        networkMonitor: NetworkPathMonitor? = nil,
        sessionProvider: SessionProvider? = nil,
        osNotificationCenter: OSNotificationCenter? = nil
    ) -> PocketSource {
        PocketSource(
            space: space ?? self.space,
            apollo: apollo ?? self.apollo,
            operations: operations ?? self.operations,
            lastRefresh: lastRefresh ?? self.lastRefresh,
            slateService: slateService ?? self.slateService,
            networkMonitor: networkMonitor ?? self.networkMonitor,
            sessionProvider: sessionProvider ?? self.sessionProvider,
            backgroundTaskManager: backgroundTaskManager ?? self.backgroundTaskManager,
            osNotificationCenter: osNotificationCenter ?? self.osNotificationCenter
        )
    }

    func test_refresh_addsFetchListOperationToQueue() {
        let session = MockSession()
        sessionProvider.session = session
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()

        source.refresh()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(operations.fetchListCall(at: 0)?.token, session.accessToken)
    }

    func test_refreshWithCompletion_callsCompletionWhenFinished() {
        sessionProvider.session = MockSession()
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refresh {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_refresh_whenTokenIsNil_callsCompletion() {
        sessionProvider.session = nil
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refresh {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 1)
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
        let item = try space.createSavedItem(remoteID: "delete-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.delete(item: item)

        let fetchedItem = try space.fetchSavedItem(byRemoteID: "delete-me")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.hasChanges)
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_delete_ifSavedItemItemHasRecommendation_doesNotDeleteSavedItemItem() throws {
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.createSavedItem(item: space.buildItem())
        let item = savedItem.item!
        item.recommendation = space.buildRecommendation()

        let remoteItemID = item.remoteID!

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byRemoteID: remoteItemID)
        XCTAssertNotNil(fetchedItem)
    }

    func test_delete_ifSavedItemItemHasNoRecommendation_doesNotDeleteSavedItemItem() throws {
        operations.stubItemMutationOperation { (_, _, _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.createSavedItem(item: space.buildItem())
        let item = savedItem.item!

        let remoteItemID = item.remoteID!

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byRemoteID: remoteItemID)
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
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_unarchive_executesSaveItemMutation_andUpdatesCreatedAtField() throws {
        let item = try space.createSavedItem(remoteID: "unarchive-me")
        item.isArchived = true

        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
        source.unarchive(item: item)

        let fetchedItem = try space.fetchSavedItem(byRemoteID: "archive-me")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.isArchived)
        XCTAssertNotNil(item.createdAt)
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_fetchSlateLineup_forwardsToSlateService() async throws {
        slateService.stubFetchSlateLineup { _ in }

        let source = subject()
        try await source.fetchSlateLineup("slate-lineup-identifier")
        XCTAssertEqual(slateService.fetchSlateLineupCall(at: 0)?.identifier, "slate-lineup-identifier")
    }

    func test_fetchSlate_forwardsToSlateService() async throws {
        slateService.stubFetchSlate { _ in }

        let source = subject()
        try await source.fetchSlate("slate-identifier")
        XCTAssertEqual(slateService.fetchSlateCall(at: 0)?.identifier, "slate-identifier")
    }

    func test_itemsController_returnsAFetchedResultsController() throws {
        let source = subject()
        let item1 = try space.createSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(1)), item: space.buildItem(title: "Item 1"))

        let itemResultsController = source.makeItemsController()
        try itemResultsController.performFetch()
        XCTAssertEqual(itemResultsController.fetchedObjects, [item1])

        let expectationForUpdatedItems = expectation(description: "updated items")
        let delegate = TestSavedItemsControllerDelegate {
            expectationForUpdatedItems.fulfill()
        }
        itemResultsController.delegate = delegate

        let item2 = try space.createSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(0)), item: space.buildItem(title: "Item 2"))

        wait(for: [expectationForUpdatedItems], timeout: 1)
        XCTAssertEqual(itemResultsController.fetchedObjects, [item1, item2])
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
        let unresolved: UnresolvedSavedItem = space.new()
        unresolved.savedItem = savedItem
        try space.save()

        source.resolveUnresolvedSavedItems()

        wait(for: [operationStarted], timeout: 1)
        try XCTAssertEqual(space.fetchUnresolvedSavedItems(), [])
    }

    func test_saveRecommendation_createsPendingItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = space.buildItem(resolvedURL: URL(string: "https://getpocket.com")!)
        let recommendation = space.buildRecommendation(item: seededItem)

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.url, URL(string: "https://getpocket.com")!)

        XCTAssertEqual(savedItem.item, seededItem)
    }

    func test_saveRecommendation_withArchivedItem_unarchivesItem_andExecutesUnarchiveOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = space.buildItem()
        let seededSavedItem = space.buildSavedItem(isArchived: true)
        seededItem.savedItem = seededSavedItem
        let recommendation = space.buildRecommendation(item: seededItem)

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem, seededSavedItem)
        XCTAssertEqual(savedItem.item, seededItem)
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
        wait(for: [expectationToRunOperation], timeout: 1)

        let archivedItems = try space.fetchArchivedItems()
        XCTAssertEqual(archivedItems.count, 1)

        let archivedItem = archivedItems[0]
        XCTAssertEqual(archivedItem.item, seededItem)
        XCTAssertFalse(archivedItem.hasChanges)
        XCTAssertNotNil(archivedItem.archivedAt)
    }

    func test_removeRecommendation_removesRecommendationFromSpace() throws {
        let recommendation1 = space.buildRecommendation()
        let recommendation2 = space.buildRecommendation()

        let source = subject()
        source.remove(recommendation: recommendation1)

        let fetched = try space.fetchRecommendations()
        XCTAssertEqual(fetched, [recommendation2])
    }

    func test_downloadImage_updatesIsDownloadedProperty() throws {
        let image: Image = space.new()

        let source = subject()
        source.download(images: [image])

        XCTAssertTrue(image.isDownloaded)
    }

    @MainActor
    func test_fetchOfflineContent_fetchesOfflineContent() async throws {
        apollo.stubFetch(
            toReturnFixtureNamed: "single-item-details",
            asResultType: SavedItemByIDQuery.self
        )

        let savedItem = try space.createSavedItem(remoteID: "a-saved-item")
        savedItem.item = nil
        try space.save()

        let source = subject()
        try await source.fetchDetails(for: savedItem)

        space.refresh(savedItem, mergeChanges: true)
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

        space.refresh(recommendation, mergeChanges: true)
        XCTAssertNotNil(recommendation.item?.article)
        XCTAssertFalse(recommendation.hasChanges)
    }

    func test_saveURL_insertsSavedItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = URL(string: "https://getpocket.com")!

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 1)

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

        let url = URL(string: "https://getpocket.com")!
        let seed = space.buildSavedItem(url: url.absoluteString)
        let seedDate = Date()
        seed.createdAt = seedDate
        try? space.save()

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)
        XCTAssertEqual(savedItems[0].url, url)
        XCTAssertGreaterThan(savedItems[0].createdAt!, seedDate)
    }

    func test_saveURL_withArchivedSavedItem_unarchivesItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = URL(string: "https://getpocket.com")!
        _ = space.buildSavedItem(url: "https://getpocket.com", isArchived: true)
        try? space.save()

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 1)

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

    func test_fetchTags_withSaved_returnsSavedTags() throws {
        let tagNames = ["tag 1", "tag 2", "tag 3"]
        _ = createItemsWithTags(3)
        _ = createItemsWithTags(1, isArchived: true)
        let source = subject()
        guard let tags = source.fetchTags() else {
            XCTFail("tags should not be nil")
            return
        }
        let names = tags.compactMap { $0.name }
        XCTAssertEqual(names.count, 3)
        XCTAssertTrue(names.contains(tagNames[0]))
        XCTAssertTrue(names.contains(tagNames[1]))
        XCTAssertTrue(names.contains(tagNames[2]))
    }

    func test_fetchTags_withArchive_returnsArchivedTags() throws {
        let tagNames = ["tag 1", "tag 2"]
        _ = createItemsWithTags(1)
        _ = createItemsWithTags(2, isArchived: true)
        let source = subject()
        guard let tags = source.fetchTags(isArchived: true) else {
            XCTFail("tags should not be nil")
            return
        }
        let names = tags.compactMap { $0.name }
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains(tagNames[0]))
        XCTAssertTrue(names.contains(tagNames[1]))
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
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_renameTag_executesUpdateTagMutation() throws {
        let tag1: Tag = space.new()
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
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    private func createItemsWithTags(_ number: Int, isArchived: Bool = false) -> [SavedItem] {
        guard number > 0 else { return [] }
        return (1...number).compactMap { num in
            let tag: Tag = space.new()
            tag.remoteID = "id \(num)"
            tag.name = "tag \(num)"
            return space.buildSavedItem(isArchived: isArchived, tags: [tag])
        }
    }
}
