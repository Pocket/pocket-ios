import XCTest
import Sync
import Combine
import Analytics
@testable import PocketKit
import CoreData


class SlateDetailViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var slateController: MockSlateController!


    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        subscriptions = []

        source = MockSource()
        tracker = MockTracker()
        slateController = MockSlateController()
        slateController.stubPerformFetch { }

        source.stubMakeSlateController { _ in
            return self.slateController
        }
    }

    func subject(
        slateID: String? = nil,
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> SlateDetailViewModel {
        SlateDetailViewModel(
            slateID: slateID ?? "abcde",
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_refresh_delegatesToSource() {
        let fetchExpectation = expectation(description: "expected to fetch slate")
        source.stubFetchSlate { _ in fetchExpectation.fulfill() }

        let viewModel = subject()
        viewModel.refresh { }
        wait(for: [fetchExpectation], timeout: 1)

        XCTAssertEqual(source.fetchSlateCall(at: 0)?.identifier, "abcde")
    }

    func test_snapshot_whenSlatesAreUpdates_updatesSnapshot() {
        let recommendations: [Recommendation] = [
            .build(remoteID: "slate-1-recommendation-1"),
            .build(remoteID: "slate-1-recommendation-2")
        ]

        let slate: Slate = .build(
            remoteID: "slate-1",
            recommendations: recommendations
        )

        let slateController = MockSlateController()
        slateController.slate = slate
        source.stubMakeSlateController { _ in
            slateController
        }

        let viewModel = subject()
        slateController.delegate?.controllerDidChangeContent(slateController)

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.sink { snapshot in
            XCTAssertEqual(
                snapshot.sectionIdentifiers,
                [.slate(slateController.slate!)]
            )

            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slate(slateController.slate!)),
                [.recommendation(recommendations[0].objectID), .recommendation(recommendations[1].objectID)]
            )

            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsSaved_updatesSnapshot() {
        let item = Item.build()
        let recommendations: [Recommendation] = [
            .build(remoteID: "slate-1-recommendation-1", item: item),
        ]
        let slate: Slate = .build(recommendations: recommendations)

        let slateController = MockSlateController()
        slateController.slate = slate
        source.stubMakeSlateController { _ in
            slateController
        }

        let viewModel = subject()
        slateController.delegate?.controllerDidChangeContent(slateController)

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            let reloaded = snapshot.reloadedItemIdentifiers.compactMap { cell -> NSManagedObjectID? in
                switch cell {
                case .loading:
                    return nil
                case .recommendation(let objectID):
                    return objectID
                }
            }
            XCTAssertEqual(reloaded, [recommendations.first!.objectID])

            snapshotExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem = SavedItem.build()

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsReadable_updatesSelectedReadable() {
        let viewModel = subject()

        let recommendation = Recommendation.build()
        slateController.slate = .build(recommendations: [
            recommendation
        ])
        viewModel.controllerDidChangeContent(slateController)

        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        let cell = SlateDetailViewModel.Cell.recommendation(recommendation.objectID)
        viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsNotReadable_updatesPresentedWebReaderURL() {
        let viewModel = subject()

        let item = Item.build()
        let recommendation = Recommendation.build(item: item)
        slateController.slate = .build(recommendations: [
            recommendation
        ])
        viewModel.controllerDidChangeContent(slateController)

        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        do {
            item.isArticle = false

            let cell = SlateDetailViewModel.Cell.recommendation(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = Imageness.isImage.rawValue

            let cell = SlateDetailViewModel.Cell.recommendation(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        do {
            item.isArticle = true
            item.imageness = nil
            item.videoness = Videoness.isVideo.rawValue

            let cell = SlateDetailViewModel.Cell.recommendation(recommendation.objectID)
            viewModel.select(cell: cell, at: IndexPath(item: 0, section: 0))
        }

        wait(for: [urlExpectation], timeout: 1)
    }

    func test_reportAction_forRecommendation_updatesSelectedRecommendationToReport() {
        let viewModel = subject()

        let recommendation = Recommendation.build()
        slateController.slate = .build(recommendations: [
            recommendation
        ])
        viewModel.controllerDidChangeContent(slateController)

        let action = viewModel.reportAction(
            for: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        let reportExpectation = expectation(description: "expected to update selected recommendation to report")
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        action?.handler?(nil)
        wait(for: [reportExpectation], timeout: 1)
    }

    func test_saveAction_whenRecommendationIsNotSaved_savesWithSource() {
        source.stubSaveRecommendation { _ in }

        let viewModel = subject()

        let recommendation = Recommendation.build()
        slateController.slate = .build(recommendations: [
            recommendation
        ])
        viewModel.controllerDidChangeContent(slateController)

        let action = viewModel.saveAction(
            for: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.saveRecommendationCall(at: 0)?.recommendation, recommendation)
    }

    func test_saveAction_whenRecommendationIsSaved_archivesWithSource() {
        source.stubArchiveRecommendation { _ in }

        let viewModel = subject()

        let item = Item.build()
        item.savedItem = .build()
        let recommendation = Recommendation.build(item: item)
        slateController.slate = .build(recommendations: [recommendation])
        viewModel.controllerDidChangeContent(slateController)

        let action = viewModel.saveAction(
            for: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )
        XCTAssertNotNil(action)

        action?.handler?(nil)
        XCTAssertEqual(source.archiveRecommendationCall(at: 0)?.recommendation, recommendation)
    }

    func test_resetSlate_keepsFirstFiveRecommendations() {
        let recommendations: [Recommendation] = [
            .build(remoteID: "recommendation-1"),
            .build(remoteID: "recommendation-2"),
            .build(remoteID: "recommendation-3"),
        ]

        let slateController = MockSlateController()
        slateController.slate = .build(recommendations: recommendations)
        source.stubMakeSlateController { _ in
            slateController
        }
        source.stubRemoveRecommendation { _ in }

        let viewModel = subject()
        viewModel.resetSlate(keeping: 1)

        XCTAssertEqual(source.removeRecommendationCall(at: 0)?.recommendation.remoteID, "recommendation-2")
        XCTAssertEqual(source.removeRecommendationCall(at: 1)?.recommendation.remoteID, "recommendation-3")
    }
}

