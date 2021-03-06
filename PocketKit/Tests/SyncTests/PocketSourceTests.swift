// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Apollo
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

        lastRefresh.stubGetLastRefresh { nil}

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
        let item = try space.seedSavedItem(remoteID: "test-item-id")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: FavoriteItemMutation) in
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
        let item = try space.seedSavedItem()
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: UnfavoriteItemMutation) in
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
        let item = try space.seedSavedItem(remoteID: "delete-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: DeleteItemMutation) in
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
        operations.stubItemMutationOperation { (_, _ , _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.seedSavedItem(item: .build())
        let item = savedItem.item!
        item.recommendation = .build()

        let remoteItemID = item.remoteID!

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byRemoteID: remoteItemID)
        XCTAssertNotNil(fetchedItem)
    }

    func test_delete_ifSavedItemItemHasNoRecommendation_doesNotDeleteSavedItemItem() throws {
        operations.stubItemMutationOperation { (_, _ , _: DeleteItemMutation) in
            TestSyncOperation { }
        }

        let savedItem = try space.seedSavedItem(item: .build())
        let item = savedItem.item!

        let remoteItemID = item.remoteID!

        let source = subject()
        source.delete(item: savedItem)

        let fetchedItem = try space.fetchItem(byRemoteID: remoteItemID)
        XCTAssertNil(fetchedItem)
    }

    func test_archive_archivesLocally_andExecutesArchiveMutation_andUpdatesArchivedAt() throws {
        let item = try space.seedSavedItem(remoteID: "archive-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: ArchiveItemMutation) in
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
        let item = try space.seedSavedItem(remoteID: "unarchive-me")
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
        let item1 = try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(1)), item: space.buildItem(title: "Item 1"))

        let itemResultsController = source.makeItemsController()
        try itemResultsController.performFetch()
        XCTAssertEqual(itemResultsController.fetchedObjects, [item1])

        let expectationForUpdatedItems = expectation(description: "updated items")
        let delegate = TestSavedItemsControllerDelegate {
            expectationForUpdatedItems.fulfill()
        }
        itemResultsController.delegate = delegate

        let item2 = try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(0)), item: space.buildItem(title: "Item 2"))

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

        let savedItem = try! space.seedSavedItem()
        let unresolved: UnresolvedSavedItem = space.new()
        unresolved.savedItem = savedItem
        try space.save()

        source.resolveUnresolvedSavedItems()

        wait(for: [operationStarted], timeout: 1)
        try XCTAssertEqual(space.fetchUnresolvedSavedItems(), [])
    }

    func test_saveRecommendation_createsPendingItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _ , _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = Item.build()
        let recommendation = Recommendation.build(item: seededItem)

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.url, URL(string: "https://getpocket.com")!)

        XCTAssertEqual(savedItem.item, seededItem)
    }

    func test_saveRecommendation_createsSavedItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _ , _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = Item.build()
        let recommendation = Recommendation.build(item: seededItem)

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
        operations.stubSaveItemOperation { _, _, _ , _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let seededItem = Item.build()
        let seededSavedItem = SavedItem.build(isArchived: true)
        seededItem.savedItem = seededSavedItem
        let recommendation = Recommendation.build(item: seededItem)

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

        let seededItem = Item.build()
        seededItem.savedItem = .build()
        let recommendation = Recommendation.build(item: seededItem)

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
        let recommendation1 = Recommendation.build()
        let recommendation2 = Recommendation.build()

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
            asResultType: SavedItemByIdQuery.self
        )

        let savedItem = try space.seedSavedItem(remoteID: "a-saved-item")
        savedItem.item = nil
        try space.save()

        let source = subject()
        try await source.fetchDetails(for: savedItem)

        space.refresh(savedItem, mergeChanges: true)
        XCTAssertNotNil(savedItem.item)
        XCTAssertFalse(savedItem.hasChanges)
    }
    
    func test_saveURL_insertsSavedItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { _, _, _ , _, _ in
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
        operations.stubSaveItemOperation { _, _, _ , _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = URL(string: "https://getpocket.com")!
        let seed: SavedItem = .build(url: url.absoluteString)
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
        operations.stubSaveItemOperation { _, _, _ , _, _ in
            return TestSyncOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let url = URL(string: "https://getpocket.com")!
        _ = SavedItem.build(url: "https://getpocket.com", isArchived: true)
        try? space.save()

        let source = subject()
        source.save(url: url)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)
        XCTAssertFalse(savedItems[0].isArchived)
    }
}
