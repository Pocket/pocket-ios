// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import Analytics
import CoreData
import PocketGraph
import SharedPocketKit
@testable import Sync
@testable import PocketKit

@MainActor
class HomeViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var space: Space!
    var networkPathMonitor: MockNetworkPathMonitor!
    var appSession: AppSession!
    var taskScheduler: MockBGTaskScheduler!
    var homeRefreshCoordinator: RefreshCoordinator!
    var subscriptions: Set<AnyCancellable> = []
    var homeController: RichFetchedResultsController<Recommendation>!
    var sharedWithYouHighlightsController: RichFetchedResultsController<SharedWithYouHighlight>!
    var recentSavesController: NSFetchedResultsController<SavedItem>!
    var user: User!
    var subscriptionStore: SubscriptionStore!
    var userDefaults: UserDefaults!
    var lastRefresh: UserDefaultsLastRefresh!
    var notificationCenter: NotificationCenter!
    var featureFlags: MockFeatureFlagService!

    override func setUp() async throws {
        try await super.setUp()
        subscriptions = []
        space = .testSpace()
        source = MockSource()
        networkPathMonitor = MockNetworkPathMonitor()
        notificationCenter = .default
        featureFlags = MockFeatureFlagService()

        taskScheduler = MockBGTaskScheduler()
        userDefaults = UserDefaults(suiteName: "HomeViewModelTests")
        lastRefresh = UserDefaultsLastRefresh(defaults: userDefaults)
        lastRefresh.reset()

        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.currentSession = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        homeRefreshCoordinator = HomeRefreshCoordinator(notificationCenter: .default, taskScheduler: taskScheduler, appSession: appSession, source: source, lastRefresh: lastRefresh)
        homeController = space.makeRecomendationsSlateLineupController(by: SyncConstants.Home.slateLineupIdentifier)
        sharedWithYouHighlightsController = space.makeSharedWithYouHighlightsController(limit: SyncConstants.Home.sharedWithYouHighlights)
        recentSavesController = space.makeRecentSavesController(limit: 5)
        subscriptionStore = MockSubscriptionStore()
        user = PocketUser(userDefaults: userDefaults)

        tracker = MockTracker()

        source.stubMakeHomeController {
            self.homeController
        }

        source.stubMakeRecentSavesController {
            self.recentSavesController
        }

        source.stubMakeSharedWithYouHighlightsController {
            self.sharedWithYouHighlightsController
        }

        source.stubViewObject { identifier in
            self.space.viewObject(with: identifier)
        }

        source.stubViewRefresh { _, _ in }

        source.stubBackgroundObject { object in
            self.space.backgroundObject(with: object)
        }
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "HomeViewModelTests")
        subscriptions = []
        try space.clear()
        subscriptionStore = nil
        try super.tearDownWithError()
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil,
        homeRefreshCoordinator: RefreshCoordinator? = nil,
        user: User? = nil,
        userDefaults: UserDefaults? = nil,
        notificationCenter: NotificationCenter? = nil
    ) -> HomeViewModel {
        return HomeViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            homeRefreshCoordinator: homeRefreshCoordinator ?? self.homeRefreshCoordinator,
            user: user ?? self.user,
            store: subscriptionStore ?? self.subscriptionStore,
            recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService(store: MockRecentSavesWidgetStore()),
            recommendationsWidgetUpdateService: RecommendationsWidgetUpdateService(store: MockRecentSavesWidgetStore()),
            userDefaults: userDefaults ?? self.userDefaults,
            notificationCenter: notificationCenter ?? self.notificationCenter,
            featureFlags: featureFlags
        )
    }

    func test_init_createsLoadingSnapshot() {
        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected to receive updated snapshot")
        viewModel.$snapshot.sink { snapshot in
            XCTAssertEqual(snapshot.sectionIdentifiers, [.loading])
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .loading), [.loading])
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_fetch_whenRecentSavesIsEmpty_andSlateLineupIsUnavailable_sendsLoadingSnapshot() {
        let viewModel = subject()

        let receivedLoadingSnapshot = expectation(description: "receivedLoadingSnapshot")
        viewModel.$snapshot.dropFirst(3).sink { snapshot in
            defer { receivedLoadingSnapshot.fulfill() }
            XCTAssertEqual(snapshot.sectionIdentifiers, [.loading])
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedLoadingSnapshot], timeout: 10)
    }

    func test_fetch_whenRecentSavesIsEmpty_andSlateLineupIsAvailable_sendsSnapshotWithSlates() throws {
        let recommendations = try (0...3).map {
            try space.createRecommendation(remoteID: "recommendation-\($0)", item: space.createItem(remoteID: "item-\($0)", givenURL: "http://example.com/item-\($0)"))
        }

        let slates = try [
            space.createSlate(remoteID: "slate-1", recommendations: Array(recommendations[0...1])),
            space.createSlate(remoteID: "slate-2", recommendations: Array(recommendations[2...3])),
        ]

        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: slates
        )
        try space.save()

        let viewModel = subject()
        let receivedSnapshot = expectation(description: "receivedSnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedSnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                slates.flatMap { slate in
                    [.slateHero(slate.objectID), .slateCarousel(slate.objectID)]
                }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slates[0].objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateCarousel(slates[0].objectID)),
                [.recommendationCarousel(recommendations[1].objectID)]
            )
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slates[1].objectID)),
                [.recommendationHero(recommendations[2].objectID)]
            )
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateCarousel(slates[1].objectID)),
                [.recommendationCarousel(recommendations[3].objectID)]
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedSnapshot], timeout: 10)
    }

    func test_fetch_whenRecentSavesAreAvailable_andSlateLineupIsUnavailable_sendsSnapshotWithRecentSaves() throws {
        let items = try (1...2).map { try space.createItem(remoteID: "item-\($0)", givenURL: "http://example.com/item-\($0)") }
        let savedItems = try (1...2).map {
            try space.createSavedItem(
                remoteID: "saved-item-\($0)",
                url: "http://example.com/item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: items[$0 - 1]
            )
        }
        try space.save()

        let viewModel = subject()
        let receivedEmptySnapshot = expectation(description: "receivedEmptySnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedEmptySnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves, .loading]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                savedItems.reversed().map { .recentSaves($0.objectID) }
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedEmptySnapshot], timeout: 10)
    }

    func test_whenSharedWithYouHasItems_andNoRecomendations_sendsSnapshotWithSharedWithYouHighlights_andLoading() throws {
        let items = try (0...5).map { try space.createItem(remoteID: "item-\($0)", givenURL: URL(string: "http://example.com/item-\($0)")?.absoluteString) }
        let sharedWithYouHighlights: [SharedWithYouHighlight] = try items.enumerated().map { index, item in
            return try space.createSharedWithYouHighlight(item: item, sortOrder: Int32(index))
        }
        try space.save()

        let viewModel = subject()
        let receivedSnapshotWithSharedWithYou = expectation(description: "receivedSnapshotWithSharedWithYou")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedSnapshotWithSharedWithYou.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .sharedWithYou),
                sharedWithYouHighlights[0...4].map { .sharedWithYou($0.objectID) }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .loading),
                [HomeViewModel.Cell.loading]
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedSnapshotWithSharedWithYou], timeout: 10)
    }

    func test_whenSharedWithYouHasItems_andRecomendations_sendsSnapshotWithSharedWithYouHighlights_andRecs() throws {
        let items = try (0...5).map { try space.createItem(remoteID: "item-\($0)", givenURL: URL(string: "http://example.com/item-\($0)")) }
        let recommendations = try items.map { try space.createRecommendation(remoteID: "recommendation-\($0.remoteID)", item: $0) }
        let slate = space.buildSlate(recommendations: recommendations)
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [slate]
        )

        let sharedWithYouItems = try (0...5).map { try space.createItem(remoteID: "sharedWithYouItem-\($0)", givenURL: URL(string: "http://example.com/sharedWithYouItem-\($0)")) }
        let sharedWithYouHighlights: [SharedWithYouHighlight] = try sharedWithYouItems.enumerated().map { index, item in
            return try space.createSharedWithYouHighlight(item: item, sortOrder: Int32(index))
        }
        try space.save()

        let viewModel = subject()
        let receivedSnapshotWithSharedWithYou = expectation(description: "receivedSnapshotWithSharedWithYou")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedSnapshotWithSharedWithYou.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slate.objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateCarousel(slate.objectID)),
                recommendations[1...4].map { .recommendationCarousel($0.objectID) }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .sharedWithYou),
                sharedWithYouHighlights[0...4].map { .sharedWithYou($0.objectID) }
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedSnapshotWithSharedWithYou], timeout: 10)
    }

    func test_fetch_whenSlateContainsMoreThanFiveRecommendations_sendsSnapshotFirstFiveRecommendations() throws {
        let items = try (0...5).map { try space.createItem(remoteID: "item-\($0)", givenURL: "http://example.com/item-\($0)") }
        let recommendations = try items.map { try space.createRecommendation(remoteID: "recommendation-\($0.remoteID)", item: $0) }
        let slate = space.buildSlate(recommendations: recommendations)
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [slate]
        )

        let viewModel = subject()
        let receivedEmptySnapshot = expectation(description: "receivedEmptySnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedEmptySnapshot.fulfill() }

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slate.objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateCarousel(slate.objectID)),
                recommendations[1...4].map { .recommendationCarousel($0.objectID) }
            )

            XCTAssertNil(
                snapshot.indexOfSection(.sharedWithYou)
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedEmptySnapshot], timeout: 10)
    }

    func test_snapshot_whenSlateLineupIsUpdated_updatesSnapshot() throws {
        let lineup = try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [
                space.createSlate(
                    remoteID: "slate-1",
                    recommendations: [
                        space.createRecommendation(
                            remoteID: "rec-1",
                            item: space.createItem(
                                remoteID: "item-1"
                            )
                        )
                    ]
                )
            ]
        )
        try space.save()

        let viewModel = subject()
        viewModel.fetch()

        var slate: Slate!
        var rec: Recommendation!

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.$snapshot.dropFirst(2).first().sink { snapshot in
            defer { snapshotSent.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.slateHero(slate.objectID)]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slate.objectID)),
                [.recommendationHero(rec.objectID)]
            )
        }.store(in: &subscriptions)

        space.delete(lineup)
        rec = space.buildRecommendation(
            remoteID: "rec-2",
            item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-123")
        )
        slate = space.buildSlate(
            remoteID: "slate-2",
            recommendations: [rec]
        )

        _ = space.buildSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [slate]
        )
        try space.save()

        wait(for: [snapshotSent], timeout: 10)
    }

    func test_snapshot_whenRecommendationIsSaved_updatesSnapshot() throws {
        let item = space.buildItem()
        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation(remoteID: "recommendation-2", item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2"))
        ]
        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: slates
        )
        try space.save()

        var savedItem: SavedItem!
        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst(2).sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves] + slates.flatMap {
                    [.slateHero($0.objectID), .slateCarousel($0.objectID)]
                }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slates[0].objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )
            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                []
            )
        }.store(in: &subscriptions)

        savedItem = space.buildSavedItem()
        item.savedItem = savedItem
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_snapshot_whenRecommendationIsArchived_updatesSnapshot() throws {
        let item = space.buildItem()
        item.savedItem = space.buildSavedItem()
        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation(remoteID: "recommendation-2", item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2"))
        ]
        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: slates
        )
        try space.save()

        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                slates.flatMap {
                    [.slateHero($0.objectID), .slateCarousel($0.objectID)]
                }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slates[0].objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )
            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                []
            )
        }.store(in: &subscriptions)

        item.savedItem?.isArchived = true
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_snapshot_whenRecommendationIsDeleted_updatesSnapshot() throws {
        let item = space.buildItem()
        item.savedItem = space.buildSavedItem()

        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation(remoteID: "recommendation-2", item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2"))
        ]

        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: slates
        )
        try space.save()

        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                slates.flatMap {
                    [.slateHero($0.objectID), .slateCarousel($0.objectID)]
                }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slateHero(slates[0].objectID)),
                [.recommendationHero(recommendations[0].objectID)]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                []
            )
        }.store(in: &subscriptions)

        space.delete(item.savedItem!)
        XCTAssertNotNil(item.savedItem?.item)
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_snapshot_whenSavedItemIsFavorited_updatesSnapshot() throws {
        let savedItem = try space.createSavedItem(
            item: space.buildItem()
        )

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves, .loading]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                [.recentSaves(savedItem.objectID)]
            )

            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                [.recentSaves(savedItem.objectID)]
            )
        }.store(in: &subscriptions)

        savedItem.isFavorite = true
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_snapshot_whenNetworkIsInitiallyAvailable_hasCorrectSnapshot() {
        source.stubFetchSlateLineup { _ in }

        let viewModel = subject()
        XCTAssertNil(viewModel.snapshot.indexOfSection(.offline))
    }

    func test_snapshot_withRecentSaves_andNetworkIsUnavailable_hasCorrectSnapshot() throws {
        let items: [SavedItem] = [
            space.buildSavedItem(createdAt: Date())
        ]
        try space.save()

        networkPathMonitor.update(status: .unsatisfied)

        let snapshotExpectation = expectation(description: "expect a snapshot")
        let viewModel = subject()
        viewModel.$snapshot.dropFirst(3).sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                [
                    .recentSaves(items[0].objectID)
                ]
            )

            XCTAssertNotNil(snapshot.indexOfSection(.offline))
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .offline), [.offline])

            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_refresh_whenNetworkIsUnavailable_updatesSnapshot() {
        source.stubFetchSlateLineup { _ in }

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected a snapshot update")
        viewModel.$snapshot.dropFirst(3).sink { snapshot in
            XCTAssertNotNil(snapshot.indexOfSection(.offline))
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .offline), [.offline])
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        networkPathMonitor.update(status: .unsatisfied)
        viewModel.refresh { }

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_refresh_delegatesToHomeRefreshCoordinator() {
        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }

        let viewModel = subject()
        viewModel.refresh { }
        wait(for: [fetchExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsReadable_updatesSelectedReadable() throws {
        let item = space.buildItem()
        let heroRec = space.buildRecommendation(item: item)
        let carouselRec = space.buildRecommendation(remoteID: "carousel-rec", item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2"))
        let recommendations = [heroRec, carouselRec]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        let readableExpectation = expectation(description: "expected to update selected readable")
        readableExpectation.expectedFulfillmentCount = 2
        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .recommendable, .webViewRecommendable:
                readableExpectation.fulfill()
            case .savedItem, .webViewSavedItem, .sharedWithYou, .webViewSharedWithYou, .none:
                XCTFail("Expected recommendation, but got \(String(describing: readableType))")
            default:
                // TODO: we might want to add a check here
                break
            }
        }.store(in: &subscriptions)

        let cells: [HomeViewModel.Cell] = [
            .recommendationHero(heroRec.objectID),
            .recommendationCarousel(carouselRec.objectID),
        ]

        for cell in cells {
            viewModel.select(
                cell: cell,
                at: IndexPath(item: 0, section: 0)
            )
        }

        wait(for: [readableExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_whenRecommendationIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        do {
            item.isArticle = false

            viewModel.select(
                cell: .recommendationHero(recommendation.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        do {
            item.isArticle = true
            item.imageness = Imageness.isImage.rawValue

            viewModel.select(
                cell: .recommendationHero(recommendation.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        do {
            item.isArticle = true
            item.imageness = nil
            item.videoness = Videoness.isVideo.rawValue

            viewModel.select(
                cell: .recommendationHero(recommendation.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        wait(for: [urlExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_withSettingsOriginalViewEnabled_showsWebViewType() throws {
        let item = space.buildItem()
        let heroRec = space.buildRecommendation(item: item)
        let carouselRec = space.buildRecommendation(remoteID: "carousel-rec", item: space.buildItem(remoteID: "item-2", givenURL: "https://example.com/items/item-2"))
        let recommendations = [heroRec, carouselRec]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        featureFlags.shouldDisableReader = true

        let readableExpectation = expectation(description: "expected a web view type")
        readableExpectation.expectedFulfillmentCount = 2

        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .webViewRecommendable:
                readableExpectation.fulfill()
            case .savedItem, .webViewSavedItem, .recommendable, .none:
                XCTFail("Expected web view saved item, but got \(String(describing: readableType))")
            default:
                // TODO: we might want to add a check here
                break
            }
        }.store(in: &subscriptions)

        let cells: [HomeViewModel.Cell] = [
            .recommendationHero(heroRec.objectID),
            .recommendationCarousel(carouselRec.objectID),
        ]

        for cell in cells {
            viewModel.select(
                cell: cell,
                at: IndexPath(item: 0, section: 0)
            )
        }

        wait(for: [readableExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecentSave_recentSaveIsReadable_updatesSelectedReadable() throws {
        let item = space.buildItem(isArticle: true)
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let readableExpectation = expectation(description: "expected to update selected readable")

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .savedItem, .webViewSavedItem:
                readableExpectation.fulfill()
            case .webViewRecommendable, .recommendable, .sharedWithYou, .webViewSharedWithYou .none:
                XCTFail("Expected recommendation, but got \(String(describing: readableType))")
            default:
                // TODO: we might want to add a check here
                break
            }
        }.store(in: &subscriptions)

        viewModel.select(
            cell: .recentSaves(savedItem.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [readableExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecentSave_recentSaveIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem(isArticle: true)
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        do {
            item.isArticle = false
            viewModel.select(
                cell: .recentSaves(savedItem.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        do {
            item.isArticle = true
            item.imageness = Imageness.isImage.rawValue

            viewModel.select(
                cell: .recentSaves(savedItem.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        do {
            item.isArticle = true
            item.imageness = nil
            item.videoness = Videoness.isVideo.rawValue

            viewModel.select(
                cell: .recentSaves(savedItem.objectID),
                at: IndexPath(item: 0, section: 0)
            )
        }

        wait(for: [urlExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecentSave_withSettingsOriginalViewEnabled_showsWebViewType() throws {
        let item = space.buildItem(isArticle: true)
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let readableExpectation = expectation(description: "expected a web view type")

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        featureFlags.shouldDisableReader = true

        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .webViewSavedItem:
                readableExpectation.fulfill()
            case .savedItem, .webViewRecommendable, .recommendable, .none:
                XCTFail("Expected web view saved item, but got \(String(describing: readableType))")
            default:
                // TODO: we might want to add a check here
                break
            }
        }.store(in: &subscriptions)

        viewModel.select(
            cell: .recentSaves(savedItem.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [readableExpectation], timeout: 10)
    }

    func test_selectSection_whenSelectingSlateSection_updatesSelectedSlateDetailViewModel() throws {
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        let slate = space.buildSlate(name: "My Awesome Slate", recommendations: recommendations)
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [slate]
        )

        let viewModel = subject()
        let detailExpectation = expectation(description: "expected selected slate detail to be updated")
        viewModel.$tappedSeeAll.dropFirst().sink { seeAll in
            defer { detailExpectation.fulfill() }

            switch seeAll {
            case .slate(let viewModel):
                XCTAssertEqual(viewModel.slateName, "My Awesome Slate")
            default:
                XCTFail("Expected seeAll to be a slate but got \(String(describing: seeAll))")
            }
        }.store(in: &subscriptions)

        viewModel.sectionHeaderViewModel(for: .slateHero(slate.objectID))?.buttonAction?()
        wait(for: [detailExpectation], timeout: 10)
    }

    func test_reportAction_forRecommendationCells_updatesSelectedRecommendationToReport() throws {
        let heroRec = space.buildRecommendation(item: space.buildItem())
        let carouselRec = space.buildRecommendation(item: space.buildItem())
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: [heroRec, carouselRec])]
        )

        let viewModel = subject()

        let reportExpectation = expectation(description: "expected to update selected recommendation to report")
        reportExpectation.expectedFulfillmentCount = 2
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        for recommendation in [heroRec, carouselRec] {
            let action = viewModel
                .recommendationHeroViewModel(for: recommendation.objectID, at: [0, 0])?
                .overflowActions?.first { $0.identifier == .report }

            XCTAssertNotNil(action)
            action?.handler?(nil)
        }

        wait(for: [reportExpectation], timeout: 10)
    }

    func test_primary_whenRecommendationIsNotSaved_savesWithSource() throws {
        source.stubSaveRecommendation { _ in }
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )
        try space.save()

        let viewModel = subject()

        let action = viewModel.recommendationHeroViewModel(
            for: recommendation.objectID, at: [0, 0]
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)
        XCTAssertEqual(
            source.saveRecommendationCall(at: 0)?.recommendation.objectID,
            recommendation.objectID
        )
    }

    func test_primary_whenRecommendationIsSaved_archivesWithSource() throws {
        source.stubArchiveRecommendation { _ in }
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]

        space.buildSavedItem(item: item)
        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        let action = viewModel.recommendationHeroViewModel(
            for: recommendation.objectID, at: [0, 0]
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)
        XCTAssertEqual(
            source.archiveRecommendationCall(at: 0)?.recommendation.objectID,
            recommendation.objectID
        )
    }

    func test_numberOfCarouselItemsForSlate_returnsAccurateCount() throws {
        let slates = [
            space.buildSlate(recommendations: (0...1).map { space.buildRecommendation(remoteID: "recommendation1-\($0)", item: space.buildItem(remoteID: "item1-\($0)", givenURL: "https://example.com/items/item1-\($0)")) }),
            space.buildSlate(recommendations: (0...2).map { space.buildRecommendation(remoteID: "recommendation2-\($0)", item: space.buildItem(remoteID: "item2-\($0)", givenURL: "https://example.com/items/item2-\($0)")) }),
            space.buildSlate(recommendations: (0...3).map { space.buildRecommendation(remoteID: "recommendation3-\($0)", item: space.buildItem(remoteID: "item3-\($0)", givenURL: "https://example.com/items/item3-\($0)")) })
        ]

        try space.createSlateLineup(
            remoteID: SyncConstants.Home.slateLineupIdentifier,
            slates: slates
        )

        let viewModel = subject()
        viewModel.fetch()

        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[0].objectID), 1)
        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[1].objectID), 2)
        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[2].objectID), 3)
    }

    func test_snapshot_whenSharedWithYouHighlightIsSaved_updatesSnapshot() throws {
        let item = space.buildItem(remoteID: "sharedWithYou-1", givenURL: URL(string: "https://example.com/items/sharedWithYou-1"))
        let sharedWithYouHighlights = [
            space.buildSharedWithYouHighlight(item: item, sortOrder: 0),
            space.buildSharedWithYouHighlight(item: space.buildItem(remoteID: "sharedWithYou-2", givenURL: URL(string: "https://example.com/items/sharedWithYou-2")), sortOrder: 1)
        ]
        try space.save()

        var savedItem: SavedItem!
        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst(1).sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves, .loading, .sharedWithYou]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .sharedWithYou),
                [.sharedWithYou(sharedWithYouHighlights[0].objectID), .sharedWithYou(sharedWithYouHighlights[1].objectID)]
            )
            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                []
            )
        }.store(in: &subscriptions)

        savedItem = space.buildSavedItem()
        item.savedItem = savedItem
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_snapshot_whenSharedWithYouHighlightIsArchived_updatesSnapshot() throws {
        let item = space.buildItem(remoteID: "sharedWithYou-1", givenURL: URL(string: "https://example.com/items/sharedWithYou-1"))
        item.savedItem = space.buildSavedItem()
        let sharedWithYouHighlights = [
            space.buildSharedWithYouHighlight(item: item, sortOrder: 0),
            space.buildSharedWithYouHighlight(item: space.buildItem(remoteID: "sharedWithYou-2", givenURL: URL(string: "https://example.com/items/sharedWithYou-2")), sortOrder: 1)
        ]
        try space.save()

        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.loading, .sharedWithYou]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .sharedWithYou),
                [.sharedWithYou(sharedWithYouHighlights[0].objectID), .sharedWithYou(sharedWithYouHighlights[1].objectID)]
            )
            XCTAssertEqual(
                snapshot.reloadedItemIdentifiers,
                []
            )
        }.store(in: &subscriptions)

        item.savedItem?.isArchived = true
        try space.save()

        wait(for: [snapshotExpectation], timeout: 10)
    }
}
