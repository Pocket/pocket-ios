import XCTest
import Combine
import Analytics
import CoreData
@testable import Sync
@testable import PocketKit


class HomeViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var slateLineupController: MockSlateLineupController!
    var recentSavesController: RecentSavesController!
    var space: Space!

    var subscriptions: Set<AnyCancellable> = []

    override func setUp() async throws {
        subscriptions = []
        space = .testSpace()

        source = MockSource()
        tracker = MockTracker()
        recentSavesController = RecentSavesController(space: space)

        slateLineupController = MockSlateLineupController()
        slateLineupController.stubPerformFetch { }

        source.stubMakeSlateLineupController {
            return self.slateLineupController
        }

        source.stubMakeSlateController { _ in
            MockSlateController()
        }

        source.stubMakeRecentSavesController {
            return self.recentSavesController
        }

        continueAfterFailure = false
    }

    override func tearDown() async throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> HomeViewModel {
        HomeViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_init_createsLoadingSnapshot() {
        source.stubFetchSlateLineup { _ in }

        let viewModel = subject()

        let snapshotExpectation = expectation(description: "expected to receive updated snapshot")
        viewModel.$snapshot.sink { snapshot in
            XCTAssertEqual(snapshot.sectionIdentifiers, [.loading])
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .loading), [.loading])
            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

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

    func test_snapshot_whenSlateLineupIsUpdated_updatesSnapshot() {
        let recommendations: [Recommendation] = [
            .build(remoteID: "slate-1-recommendation-1"),
            .build(remoteID: "slate-1-recommendation-2"),
            .build(remoteID: "slate-2-recommendation-1"),
            .build(remoteID: "slate-3-recommendation-1"),
        ]
        let slates: [Slate] = [
            .build(
                remoteID: "slate-1",
                recommendations: [recommendations[0], recommendations[1]]
            ),
            .build(
                remoteID: "slate-2",
                recommendations: [recommendations[2]]
            ),
            .build(
                remoteID: "slate-3",
                recommendations: [recommendations[3]]
            ),
        ]

        let slateLineupController = MockSlateLineupController()
        slateLineupController.slateLineup = SlateLineup.build(slates: slates)
        source.stubMakeSlateLineupController {
            slateLineupController
        }

        let viewModel = subject()
        slateLineupController.delegate?.controllerDidChangeContent(slateLineupController)

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.sink { snapshot in
            XCTAssertEqual(snapshot.sectionIdentifiers, [.slateHero(slates[0].objectID), .slateCarousel(slates[0].objectID), .slateHero(slates[1].objectID), .slateHero(slates[2].objectID)])

            let firstSlate = snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[0]) + snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[1])
            let firstSlateRecommendations = firstSlate.compactMap { cell -> NSManagedObjectID? in
                switch cell {
                case .loading, .recentSaves:
                    return nil
                case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
                    return objectID
                }
            }
            XCTAssertEqual(
                firstSlateRecommendations,
                [recommendations[0].objectID, recommendations[1].objectID]
            )

            let secondSlate = snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[2])
            let secondSlateRecommendations = secondSlate.compactMap { cell -> NSManagedObjectID? in
                switch cell {
                case .loading, .recentSaves:
                    return nil
                case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
                    return objectID
                }
            }
            XCTAssertEqual(
                secondSlateRecommendations,
                [recommendations[2].objectID]
            )

            let thirdSlate = snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[3])
            let thirdSlateRecommendations = thirdSlate.compactMap { cell -> NSManagedObjectID? in
                switch cell {
                case .loading, .recentSaves:
                    return nil
                case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
                    return objectID
                }
            }
            XCTAssertEqual(
                thirdSlateRecommendations,
                [recommendations[3].objectID]
            )

            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsSaved_updatesSnapshot() {
        let item = Item.build()
        let recommendations: [Recommendation] = [.build(remoteID: "slate-1-recommendation-1", item: item)]
        let slates: [Slate] = [.build(recommendations: recommendations)]

        let slateLineupController = MockSlateLineupController()
        slateLineupController.slateLineup = SlateLineup.build(slates: slates)
        source.stubMakeSlateLineupController {
            slateLineupController
        }

        let viewModel = subject()
        slateLineupController.delegate?.controllerDidChangeContent(slateLineupController)

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            let reloaded = snapshot.reloadedItemIdentifiers.compactMap { cell -> NSManagedObjectID? in
                switch cell {
                case .loading, .recentSaves:
                    return nil
                case .recommendationHero(let objectID), .recommendationCarousel(let objectID):
                    return objectID
                }
            }
            XCTAssertEqual(reloaded, recommendations.map { $0.objectID })

            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem = SavedItem.build()

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingCarouselRecommendation_recommendationIsReadable_updatesSelectedReadable() {
        let viewModel = subject()

        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        let cell = HomeViewModel.Cell.recommendationHero(recommendation.objectID)
        viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingHeroRecommendation_recommendationIsReadable_updatesSelectedReadable() {
        let viewModel = subject()

        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        let cell = HomeViewModel.Cell.recommendationCarousel(recommendation.objectID)
        viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))

        wait(for: [readableExpectation], timeout: 1)
    }
    
    func test_selectCell_whenSelectingHeroRecommendation_recommendationIsNotReadable_updatesPresentedWebReaderURL() {
        let viewModel = subject()
        let item = Item.build()
        let recommendation = Recommendation.build(item: item)
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        do {
            item.isArticle = false

            let cell = HomeViewModel.Cell.recommendationHero(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = Imageness.isImage.rawValue

            let cell = HomeViewModel.Cell.recommendationHero(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = nil
            item.videoness = Videoness.isVideo.rawValue

            let cell = HomeViewModel.Cell.recommendationHero(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        wait(for: [urlExpectation], timeout: 1)
    }
    
    func test_selectCell_whenSelectingCarouselRecommendation_recommendationIsNotReadable_updatesPresentedWebReaderURL() {
        let viewModel = subject()
        let item = Item.build()
        let recommendation = Recommendation.build(item: item)
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        do {
            item.isArticle = false

            let cell = HomeViewModel.Cell.recommendationCarousel(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = Imageness.isImage.rawValue

            let cell = HomeViewModel.Cell.recommendationCarousel(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = nil
            item.videoness = Videoness.isVideo.rawValue

            let cell = HomeViewModel.Cell.recommendationCarousel(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        wait(for: [urlExpectation], timeout: 1)
    }
    
    func test_selectSection_whenSelectingSlateSection_updatesSelectedSlateDetailViewModel() {
        let viewModel = subject()
        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let detailExpectation = expectation(description: "expected selected slate detail to be updated")
        viewModel.$selectedSlateDetailViewModel.dropFirst().sink { viewModel in
            XCTAssertNotNil(viewModel)
            detailExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(slate: .build())

        wait(for: [detailExpectation], timeout: 1)
    }

    func test_reportAction_forHeroRecommendation_updatesSelectedRecommendationToReport() {
        let viewModel = subject()
        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let cell = HomeViewModel.Cell.recommendationHero(recommendation.objectID)
        let action = viewModel.reportAction(for: cell, at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(action)

        let reportExpectation = expectation(description: "expected to update selected recommendation to report")
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        action?.handler?(nil)
        wait(for: [reportExpectation], timeout: 1)
    }
    
    func test_reportAction_forCarouselRecommendation_updatesSelectedRecommendationToReport() {
        let viewModel = subject()
        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let cell = HomeViewModel.Cell.recommendationCarousel(recommendation.objectID)
        let action = viewModel.reportAction(for: cell, at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(action)

        let reportExpectation = expectation(description: "expected to update selected recommendation to report")
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        action?.handler?(nil)
        wait(for: [reportExpectation], timeout: 1)
    }

    func test_saveAction_whenHeroRecommendationIsNotSaved_savesWithSource() {
        source.stubSaveRecommendation { _ in }

        let viewModel = subject()
        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let action = viewModel.saveAction(
            for: .recommendationHero(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.saveRecommendationCall(at: 0)?.recommendation, recommendation)
    }
    
    func test_saveAction_whenCarouselRecommendationIsNotSaved_savesWithSource() {
        source.stubSaveRecommendation { _ in }

        let viewModel = subject()
        let recommendation = Recommendation.build()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let action = viewModel.saveAction(
            for: .recommendationCarousel(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.saveRecommendationCall(at: 0)?.recommendation, recommendation)
    }

    func test_saveAction_whenHeroRecommendationIsSaved_archivesWithSource() {
        source.stubArchiveRecommendation { _ in }

        let item = Item.build()
        item.savedItem = .build()
        let recommendation = Recommendation.build(item: item)

        let viewModel = subject()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let action = viewModel.saveAction(
            for: .recommendationHero(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.archiveRecommendationCall(at: 0)?.recommendation, recommendation)
    }
    
    func test_saveAction_whenCarouselRecommendationIsSaved_archivesWithSource() {
        source.stubArchiveRecommendation { _ in }

        let item = Item.build()
        item.savedItem = .build()
        let recommendation = Recommendation.build(item: item)

        let viewModel = subject()
        slateLineupController.slateLineup = .build(
            slates: [.build(recommendations: [recommendation])]
        )
        viewModel.controllerDidChangeContent(slateLineupController)

        let action = viewModel.saveAction(
            for: .recommendationCarousel(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.archiveRecommendationCall(at: 0)?.recommendation, recommendation)
    }
    
    func test_snapshot_withSavedItems_fetchesRecentSavedItemsSections() throws {
        let items: [SavedItem] = [.build(createdAt: .init(timeIntervalSince1970: TimeInterval(1))), .build(createdAt: .init(timeIntervalSince1970: TimeInterval(0)))]
        try space.save()
        
        let expectSnapshot = expectation(description: "expect a snapshot")
        let viewModel = subject()
        viewModel.$snapshot.dropFirst().sink { snapshot in
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .recentSaves),
                [
                    .recentSaves(items[0].objectID),
                    .recentSaves(items[1].objectID)
                ]
            )

            expectSnapshot.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [expectSnapshot], timeout: 1)
    }
    
    func test_snapshot_withNoSavedItems_doesNotHaveRecentSavedItemsSection() {
        let expectSnapshot = expectation(description: "expect a snapshot")
        let viewModel = subject()
        viewModel.$snapshot.dropFirst().sink { snapshot in
            XCTAssertNil(snapshot.indexOfSection(.recentSaves))
            expectSnapshot.fulfill()
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [expectSnapshot], timeout: 1)
    }
}
