import XCTest
import Sync
import Combine
import Analytics
import CoreData
import PocketGraph

@testable import Sync
@testable import PocketKit

class SlateDetailViewModelTests: XCTestCase {
    var space: Space!
    var source: MockSource!
    var tracker: MockTracker!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()

        source.mainContext = space.context
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        slate: Slate,
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> SlateDetailViewModel {
        SlateDetailViewModel(
            slate: slate,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker
        )
    }

    func test_refresh_delegatesToSource() throws {
        let slate = try space.createSlate(remoteID: "abcde")
        let viewModel = subject(slate: slate)

        let fetchExpectation = expectation(description: "expected to fetch slate")
        source.stubFetchSlate { _ in
            fetchExpectation.fulfill()
        }
        viewModel.refresh { }

        wait(for: [fetchExpectation], timeout: 1)
        XCTAssertEqual(source.fetchSlateCall(at: 0)?.identifier, "abcde")
    }

    func test_fetch_whenRecentSavesIsEmpty_andSlateLineupIsUnavailable_sendsLoadingSnapshot() throws {
        let slate: Slate = try space.createSlate(
            remoteID: "slate-1",
            recommendations: []
        )
        let viewModel = subject(slate: slate)

        let receivedLoadingSnapshot = expectation(description: "receivedLoadingSnapshot")
        viewModel.$snapshot.sink { snapshot in
            defer { receivedLoadingSnapshot.fulfill() }
            XCTAssertEqual(snapshot.sectionIdentifiers, [.loading])
        }.store(in: &subscriptions)

        viewModel.fetch()

        wait(for: [receivedLoadingSnapshot], timeout: 1)
    }

    func test_fetch_sendsSnapshotWithItemForEachRecommendation() throws {
        let recommendations: [Recommendation] = [
            space.buildRecommendation(remoteID: "slate-1-recommendation-1"),
            space.buildRecommendation(remoteID: "slate-1-recommendation-2")
        ]

        let slate: Slate = try space.createSlate(
            remoteID: "slate-1",
            recommendations: recommendations
        )

        let viewModel = subject(slate: slate)

        let snapshotExpectation = expectation(description: "expected snapshot to update")
        viewModel.$snapshot.dropFirst().sink { snapshot in
            defer { snapshotExpectation.fulfill() }

            XCTAssertEqual(snapshot.sectionIdentifiers, [.slate(slate)])
            XCTAssertEqual(
                snapshot.itemIdentifiers(inSection: .slate(slate)),
                [
                    .recommendation(recommendations[0].objectID),
                    .recommendation(recommendations[1].objectID)
                ]
            )
        }.store(in: &subscriptions)

        viewModel.fetch()
        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_snapshot_whenRecommendationIsSaved_updatesSnapshot() throws {
        let item = space.buildItem()
        let recommendations = [
            space.buildRecommendation(
                remoteID: "slate-1-recommendation-1",
                item: item
            ),
        ]

        let slate = try space.createSlate(recommendations: recommendations)
        let viewModel = subject(slate: slate)

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

        item.savedItem = space.buildSavedItem()
        try space.save()

        wait(for: [snapshotExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsReadable_updatesSelectedReadable() throws {
        let recommendation = space.buildRecommendation()
        let slate = try space.createSlate(recommendations: [recommendation])

        let viewModel = subject(slate: slate)

        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.select(
            cell: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [readableExpectation], timeout: 1)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])

        let viewModel = subject(slate: slate)

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

    func test_reportAction_forRecommendation_updatesSelectedRecommendationToReport() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])

        let viewModel = subject(slate: slate)
        let reportExpectation = expectation(description: "expected to update selected recommendation to report")
        viewModel.$selectedRecommendationToReport.dropFirst().sink { recommendation in
            XCTAssertNotNil(recommendation)
            reportExpectation.fulfill()
        }.store(in: &subscriptions)

        let action = viewModel
            .recommendationViewModel(for: recommendation.objectID, at: [0, 0])?
            .overflowActions?
            .first { $0.identifier == .report }
        XCTAssertNotNil(action)

        action?.handler?(nil)
        wait(for: [reportExpectation], timeout: 1)
    }

    func test_primaryAction_whenRecommendationIsNotSaved_savesWithSource() throws {
        source.stubSaveRecommendation { _ in }

        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])
        let viewModel = subject(slate: slate)

        let action = viewModel
            .recommendationViewModel(for: recommendation.objectID, at: [0, 0])?
            .primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)

        XCTAssertEqual(source.saveRecommendationCall(at: 0)?.recommendation, recommendation)
    }

    func test_primaryAction_whenRecommendationIsSaved_archivesWithSource() throws {
        source.stubArchiveRecommendation { _ in }

        let item = space.buildItem()
        space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])
        let viewModel = subject(slate: slate)

        let action = viewModel.recommendationViewModel(
            for: recommendation.objectID,
            at: IndexPath(item: 0, section: 0)
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)

        XCTAssertEqual(source.archiveRecommendationCall(at: 0)?.recommendation, recommendation)
    }
}
