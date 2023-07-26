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

class SlateDetailViewModelTests: XCTestCase {
    var space: Space!
    var source: MockSource!
    var tracker: MockTracker!
    var subscriptions: Set<AnyCancellable> = []
    var user: User!
    var userDefaults: UserDefaults!
    var featureFlags: MockFeatureFlagService!
    private var subscriptionStore: SubscriptionStore!
    private var networkPathMonitor: MockNetworkPathMonitor!

    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()
        userDefaults = UserDefaults(suiteName: "SlateDetailViewModelTests")
        user = PocketUser(userDefaults: userDefaults)
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
        source.stubViewObject { identifier in
            self.space.viewObject(with: identifier)
        }

        source.stubViewRefresh { object, flag in
            self.space.viewContext.refresh(object, mergeChanges: flag)
        }

        featureFlags = MockFeatureFlagService()
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: "SlateDetailViewModelTests")
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        slate: Slate,
        source: Source? = nil,
        tracker: Tracker? = nil,
        user: User? = nil,
        userDefaults: UserDefaults? = nil
    ) -> SlateDetailViewModel {
        SlateDetailViewModel(
            slate: slate,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            user: user ?? self.user,
            store: subscriptionStore ?? self.subscriptionStore,
            userDefaults: userDefaults ?? self.userDefaults,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            featureFlags: featureFlags
        )
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

        wait(for: [receivedLoadingSnapshot], timeout: 10)
    }

    func test_fetch_sendsSnapshotWithItemForEachRecommendation() throws {
        let recommendations: [Recommendation] = [
            space.buildRecommendation(remoteID: "slate-1-recommendation-1", item: space.buildItem()),
            space.buildRecommendation(remoteID: "slate-1-recommendation-2", item: space.buildItem())
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
        wait(for: [snapshotExpectation], timeout: 10)
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
        try space.save()
        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)

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

        wait(for: [snapshotExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsReadable_updatesSelectedReadable() throws {
        let savedItem = try space.createSavedItem(item: space.buildItem())
        let recommendation = space.buildRecommendation(item: savedItem.item!)
        let slate = try space.createSlate(recommendations: [recommendation])
        try space.save()
        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)

        let readableExpectation = expectation(description: "expected to update selected readable")
        viewModel.$selectedReadableViewModel.dropFirst().sink { readable in
            readableExpectation.fulfill()
        }.store(in: &subscriptions)

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        viewModel.select(
            cell: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [readableExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_recommendationIsNotReadable_updatesPresentedWebReaderURL() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])
        try space.save()
        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)

        let urlExpectation = expectation(description: "expected to update presented URL")
        urlExpectation.expectedFulfillmentCount = 3
        viewModel.$presentedWebReaderURL.filter { $0 != nil }.sink { readable in
            urlExpectation.fulfill()
        }.store(in: &subscriptions)

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

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

        wait(for: [urlExpectation], timeout: 10)
    }

    func test_selectCell_whenSelectingRecommendation_withSettingsOriginalViewEnabled_setsWebViewURL() throws {
        let savedItem = try space.createSavedItem(item: space.buildItem())
        let recommendation = space.buildRecommendation(item: savedItem.item!)
        let slate = try space.createSlate(recommendations: [recommendation])
        try space.save()
        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)
        featureFlags.shouldDisableReader = true

        let webViewExpectation = expectation(description: "expected to set web view url")
        viewModel.$presentedWebReaderURL.dropFirst().sink { readable in
            webViewExpectation.fulfill()
        }.store(in: &subscriptions)

        featureFlags.stubIsAssigned { flag, variant in
            if flag == .disableReader {
                return false
            }
            XCTFail("Unknown feature flag")
            return false
        }

        viewModel.select(
            cell: .recommendation(recommendation.objectID),
            at: IndexPath(item: 0, section: 0)
        )

        wait(for: [webViewExpectation], timeout: 10)
    }

    func test_reportAction_forRecommendation_updatesSelectedRecommendationToReport() throws {
        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])
        try space.save()

        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)
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
        wait(for: [reportExpectation], timeout: 10)
    }

    func test_primaryAction_whenRecommendationIsNotSaved_savesWithSource() throws {
        source.stubSaveRecommendation { _ in }

        let item = space.buildItem()
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])
        try space.save()

        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)

        let action = viewModel
            .recommendationViewModel(for: recommendation.objectID, at: [0, 0])?
            .primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)

        XCTAssertEqual(source.saveRecommendationCall(at: 0)?.recommendation.objectID, recommendation.objectID)
    }

    func test_primaryAction_whenRecommendationIsSaved_archivesWithSource() throws {
        source.stubArchiveRecommendation { _ in }

        let item = space.buildItem()
        space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(item: item)
        let slate = try space.createSlate(recommendations: [recommendation])

        try space.save()
        let viewModel = subject(slate: space.viewObject(with: slate.objectID) as! Slate)
        let action = viewModel.recommendationViewModel(
            for: recommendation.objectID,
            at: IndexPath(item: 0, section: 0)
        )?.primaryAction
        XCTAssertNotNil(action)
        action?.handler?(nil)

        XCTAssertEqual(source.archiveRecommendationCall(at: 0)?.recommendation.objectID, recommendation.objectID)
    }
}
