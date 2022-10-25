import XCTest
import Combine
import Analytics
import CoreData
import PocketGraph
@testable import Sync
@testable import PocketKit

class HomeViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var space: Space!
    var networkPathMonitor: MockNetworkPathMonitor!

    var subscriptions: Set<AnyCancellable> = []

    override func setUp() async throws {
        subscriptions = []
        space = .testSpace()
        source = MockSource()
        source.mainContext = space.context
        networkPathMonitor = MockNetworkPathMonitor()

        tracker = MockTracker()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil
    ) -> HomeViewModel {
        HomeViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor
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

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_fetch_whenRecentSavesIsEmpty_andSlateLineupIsUnavailable_sendsLoadingSnapshot() {
        let viewModel = subject()

        let receivedLoadingSnapshot = expectation(description: "receivedLoadingSnapshot")
        viewModel.$snapshot.sink { snapshot in
            defer { receivedLoadingSnapshot.fulfill() }
            XCTAssertEqual(snapshot.sectionIdentifiers, [.loading])
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedLoadingSnapshot], timeout: 1)
    }

    func test_fetch_whenRecentSavesIsEmpty_andSlateLineupIsAvailable_sendsSnapshotWithSlates() throws {
        let recommendations = try (0...3).map {
            try space.createRecommendation(item: space.createItem(remoteID: "item-\($0)"))
        }

        let slates = try [
            space.createSlate(recommendations: Array(recommendations[0...1])),
            space.createSlate(recommendations: Array(recommendations[2...3])),
        ]

        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

        let viewModel = subject()
        let receivedEmptySnapshot = expectation(description: "receivedEmptySnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedEmptySnapshot.fulfill() }
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

        wait(for: [receivedEmptySnapshot], timeout: 1)
    }

    func test_fetch_whenRecentSavesAreAvailable_andSlateLineupIsUnavailable_sendsSnapshotWithRecentSaves() throws {
        let items = try (1...2).map { try space.createItem(remoteID: "item-\($0)") }
        let savedItems = try (1...2).map {
            try space.createSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: items[$0 - 1]
            )
        }

        let viewModel = subject()
        let receivedEmptySnapshot = expectation(description: "receivedEmptySnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedEmptySnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                savedItems.reversed().map { .recentSaves($0.objectID) }
            )
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedEmptySnapshot], timeout: 1)
    }

    func test_fetch_whenRecentSavesAndSlateLineupAreAvailable_sendsSnapshotWithRecentSavesAndSlates() throws {
        let items = (1...4).map { space.buildItem(remoteID: "item-\($0)") }
        let recommendations = items.map { space.buildRecommendation(item: $0) }
        let slates = [
            space.buildSlate(recommendations: Array(recommendations[0...1])),
            space.buildSlate(recommendations: Array(recommendations[2...3])),
        ]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

        let savedItems = try (1...2).map {
            try space.createSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: items[$0 - 1]
            )
        }

        let viewModel = subject()
        let receivedEmptySnapshot = expectation(description: "receivedEmptySnapshot")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
            defer { receivedEmptySnapshot.fulfill() }
            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.recentSaves] + slates.flatMap {
                    [.slateHero($0.objectID), .slateCarousel($0.objectID)]
                }
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                savedItems.reversed().map { .recentSaves($0.objectID) }
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

        wait(for: [receivedEmptySnapshot], timeout: 1)
    }

    func test_fetch_whenSlateContainsMoreThanFiveRecommendations_sendsSnapshotFirstFiveRecommendations() throws {
        let items = try (0...5).map { try space.createItem(remoteID: "item-\($0)") }
        let recommendations = try items.map { try space.createRecommendation(item: $0) }
        let slate = space.buildSlate(recommendations: recommendations)
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
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
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedEmptySnapshot], timeout: 1)
    }

    func test_snapshot_whenSlateLineupIsUpdated_updatesSnapshot() throws {
        let lineup = try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
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

        let viewModel = subject()
        viewModel.fetch()

        var slate: Slate!
        var rec: Recommendation!

        let snapshotSent = expectation(description: "snapshotSent")
        viewModel.$snapshot.dropFirst().first().sink { snapshot in
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
            item: space.buildItem(remoteID: "item-2")
        )
        slate = space.buildSlate(
            remoteID: "slate-2",
            recommendations: [rec]
        )

        _ = space.buildSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [slate]
        )
        try space.save()

        wait(for: [snapshotSent], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsSaved_updatesSnapshot() throws {
        let item = space.buildItem()
        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation()
        ]
        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

        var savedItem: SavedItem!
        let viewModel = subject()
        viewModel.fetch()

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
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
                [.recommendationHero(recommendations[0].objectID)]
            )
        }.store(in: &subscriptions)

        savedItem = space.buildSavedItem()
        item.savedItem = savedItem
        try space.save()

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsArchived_updatesSnapshot() throws {
        let item = space.buildItem()
        item.savedItem = space.buildSavedItem()
        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation()
        ]
        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

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
                [.recommendationHero(recommendations[0].objectID)]
            )
        }.store(in: &subscriptions)

        item.savedItem?.isArchived = true
        try space.save()

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsDeleted_updatesSnapshot() throws {
        let item = space.buildItem()
        item.savedItem = space.buildSavedItem()

        let recommendations = [
            space.buildRecommendation(item: item),
            space.buildRecommendation()
        ]
        let slates: [Slate] = [space.buildSlate(recommendations: recommendations)]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

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
                [.recommendationHero(recommendations[0].objectID)]
            )
        }.store(in: &subscriptions)

        space.delete(item.savedItem!)
        XCTAssertNotNil(item.savedItem?.item)
        try space.save()

        wait(for: [snapshotExpectation], timeout: 1)
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
                [.recentSaves]
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

        wait(for: [snapshotExpectation], timeout: 1)
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
         viewModel.$snapshot.dropFirst().sink { snapshot in
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
        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_refresh_whenNetworkIsUnavailable_updatesSnapshot() {
        source.stubFetchSlateLineup { _ in }

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected a snapshot update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            XCTAssertNotNil(snapshot.indexOfSection(.offline))
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .offline), [.offline])
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        networkPathMonitor.update(status: .unsatisfied)
        viewModel.refresh { }

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_refresh_delegatesToSource() {
        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }

        let viewModel = subject()
        viewModel.refresh { }
        wait(for: [fetchExpectation], timeout: 1)

        XCTAssertEqual(source.fetchSlateLineupCall(at: 0)?.identifier, "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1")
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsReadable_updatesSelectedReadable() throws {
        let heroRec = space.buildRecommendation()
        let carouselRec = space.buildRecommendation()
        let recommendations = [heroRec, carouselRec]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        let readableExpectation = expectation(description: "expected to update selected readable")
        readableExpectation.expectedFulfillmentCount = 2
        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .recommendation:
                readableExpectation.fulfill()
            case .savedItem, .none:
                XCTFail("Expected recommendation, but got \(String(describing: readableType))")
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

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecommendation_whenRecommendationIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
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

        wait(for: [urlExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecentSave_recentSaveIsReadable_updatesSelectedReadable() throws {
        let item = space.buildItem(isArticle: true)
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableType.dropFirst().sink { readableType in
            switch readableType {
            case .savedItem:
                readableExpectation.fulfill()
            case .recommendation, .none:
                XCTFail("Expected recommendation, but got \(String(describing: readableType))")
            }
        }.store(in: &subscriptions)

        viewModel.select(
            cell: .recentSaves(savedItem.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecentSave_recentSaveIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem(isArticle: true)
        let savedItem = space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()
        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
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

        wait(for: [urlExpectation], timeout: 1)
    }

    func test_selectSection_whenSelectingSlateSection_updatesSelectedSlateDetailViewModel() throws {
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        let slate = space.buildSlate(name: "My Awesome Slate", recommendations: recommendations)
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
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
        wait(for: [detailExpectation], timeout: 1)
    }

    func test_reportAction_forRecommendationCells_updatesSelectedRecommendationToReport() throws {
        let heroRec = space.buildRecommendation()
        let carouselRec = space.buildRecommendation()
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
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

        wait(for: [reportExpectation], timeout: 1)
    }

    func test_primary_whenRecommendationIsNotSaved_savesWithSource() throws {
        source.stubSaveRecommendation { _ in }
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        let action = viewModel.recommendationHeroViewModel(
            for: recommendation.objectID, at: [0, 0]
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)
        XCTAssertEqual(
            source.saveRecommendationCall(at: 0)?.recommendation,
            recommendation
        )
    }

    func test_primary_whenRecommendationIsSaved_archivesWithSource() throws {
        source.stubArchiveRecommendation { _ in }
        let item = space.buildItem(isArticle: true)
        let recommendation = space.buildRecommendation(item: item)
        let recommendations = [recommendation]

        space.buildSavedItem(item: item)
        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: [space.buildSlate(recommendations: recommendations)]
        )

        let viewModel = subject()

        let action = viewModel.recommendationHeroViewModel(
            for: recommendation.objectID, at: [0, 0]
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)
        XCTAssertEqual(
            source.archiveRecommendationCall(at: 0)?.recommendation,
            recommendation
        )
    }

    func test_numberOfCarouselItemsForSlate_returnsAccurateCount() throws {
        let slates = [
            space.buildSlate(recommendations: (0...1).map { _ in space.buildRecommendation() }),
            space.buildSlate(recommendations: (0...2).map { _ in space.buildRecommendation() }),
            space.buildSlate(recommendations: (0...3).map { _ in space.buildRecommendation() })
        ]

        try space.createSlateLineup(
            remoteID: HomeViewModel.lineupIdentifier,
            slates: slates
        )

        let viewModel = subject()
        viewModel.fetch()

        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[0].objectID), 1)
        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[1].objectID), 2)
        XCTAssertEqual(viewModel.numberOfCarouselItemsForSlate(with: slates[2].objectID), 3)
    }
}
