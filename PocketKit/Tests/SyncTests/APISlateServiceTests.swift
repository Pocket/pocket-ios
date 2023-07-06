// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import Apollo
import PocketGraph

@testable import Sync

class APISlateServiceTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        apollo = MockApolloClient()
        space = .testSpace()
        try space.backgroundContext.performAndWait {
            try space.clear()
            try space.save()
        }
    }

    func subject(
        apollo: MockApolloClient? = nil,
        space: Space? = nil
    ) -> APISlateService {
        APISlateService(
            apollo: apollo ?? self.apollo,
            space: space ?? self.space
        )
    }
}

extension APISlateServiceTests {
    @MainActor
    func test_fetchSlateLineup_performsCorrectQuery() async throws {
        apollo.stubFetch(toReturnFixtureNamed: "slates", asResultType: GetSlateLineupQuery.self)

        let service = subject()
        try await service.fetchSlateLineup("slate-lineup-identifier")

        let fetchCall: MockApolloClient.FetchCall<GetSlateLineupQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(fetchCall)
        XCTAssertEqual(fetchCall?.query.lineupID, "slate-lineup-identifier")
        XCTAssertEqual(fetchCall?.query.maxRecommendations, SyncConstants.Home.recomendationsPerSlateFromSlateLineup)
    }

    @MainActor
    func test_fetchSlateLineup_emptySpace_savesLineupInSpace() async throws {
        apollo.stubFetch(toReturnFixtureNamed: "slates", asResultType: GetSlateLineupQuery.self)

        let service = subject()
        try await service.fetchSlateLineup("slate-lineup-identifier")

        let lineups = try space.fetchSlateLineups()
        XCTAssertEqual(lineups.count, 1)

        let lineup = lineups[0]
        XCTAssertEqual(lineup.remoteID, "slate-lineup-1")
        XCTAssertEqual(lineup.requestID, "slate-lineup-1-request")
        XCTAssertEqual(lineup.experimentID, "slate-lineup-1-experiment")

        let slates = lineup.slates?.compactMap { $0 as? Slate } ?? []
        XCTAssertEqual(slates.count, 2)

        do {
            let slate = slates[0]
            XCTAssertEqual(slate.remoteID, "slate-1")
            XCTAssertEqual(slate.requestID, "slate-1-request")
            XCTAssertEqual(slate.experimentID, "slate-1-experiment")
            XCTAssertEqual(slate.name, "Slate 1")
            XCTAssertEqual(slate.slateDescription, "The description of slate 1")

            let recommendations = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []
            XCTAssertEqual(recommendations.count, 2)

            do {
                let recommendation = recommendations[0]
                XCTAssertEqual(recommendation.remoteID, "slate-1-rec-1slate-1")

                let item = recommendation.item
                XCTAssertNotNil(item)
                XCTAssertEqual(item.remoteID, "item-1")
                XCTAssertEqual(item.givenURL, "https://given.example.com/slate-1-rec-1")
                XCTAssertEqual(item.resolvedURL, "https://resolved.example.com/rec-1")
                XCTAssertEqual(item.title, "Slate 1, Recommendation 1")
                XCTAssertEqual(item.language, "en")
                XCTAssertEqual(item.topImageURL?.absoluteString, "http://example.com/slate-1-rec-1/top-image.png")
                XCTAssertEqual(item.timeToRead, 1)
                XCTAssertEqual(item.excerpt, "Cursus Aenean Elit")
                XCTAssertEqual(item.datePublished?.timeIntervalSince1970, 1609502461)
                XCTAssertEqual(item.domain, "slate-1-rec-1.example.com")
                XCTAssertEqual(item.domainMetadata?.name, "Lifehacker")
                XCTAssertEqual(item.domainMetadata?.logo?.absoluteString, "https://slate-1-rec-1.example.com/logo.png")
                XCTAssertEqual(item.isArticle, true)
                XCTAssertEqual(item.hasImage, .hasImages)
                XCTAssertEqual(item.hasVideo, .hasVideos)

                let images = item.images?.compactMap { $0 as? Image } ?? []
                XCTAssertEqual(images[0].source, URL(string: "http://example.com/rec-1/image-1.jpg"))
            }

            do {
                let recommendation = recommendations[1]
                XCTAssertEqual(recommendation.remoteID, "slate-1-rec-2slate-1")
                XCTAssertNotNil(recommendation.item)
            }
        }

        do {
            let slate = slates[1]
            XCTAssertEqual(slate.remoteID, "slate-2")
            XCTAssertEqual(slate.requestID, "slate-2-request")
            XCTAssertEqual(slate.experimentID, "slate-2-experiment")
            XCTAssertEqual(slate.name, "Slate 2")
            XCTAssertEqual(slate.slateDescription, "The description of slate 2")

            let recommendations = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []
            XCTAssertEqual(recommendations.count, 1)

            do {
                let recommendation = recommendations[0]
                XCTAssertEqual(recommendation.remoteID, "slate-2-rec-1slate-2")
            }
        }
    }

    @MainActor
    func test_fetchSlateLineup_existingSlateLineup_updatesExistingSpace() async throws {
        apollo.stubFetch(toReturnFixtureNamed: "slates", asResultType: GetSlateLineupQuery.self)

        let item = space.buildItem(remoteID: "item-1-seed")
        let recommendation = space.buildRecommendation(remoteID: "slate-1-recommendation-1-seed", item: item)
        let slate = space.buildSlate(remoteID: "slate-1-seed", recommendations: [recommendation])
        space.buildSlateLineup(slates: [slate])
        try self.space.save()

        let service = subject()
        try await service.fetchSlateLineup("slate-lineup-identifier")

        // 1. Update existing slate lineup
        let lineups = try space.fetchSlateLineups()
        XCTAssertEqual(lineups.count, 1)

        // 2. Old slates should be deleted
        let fetchedSlates = try space.fetchSlates()
        let fetchedSlateIDs = fetchedSlates.map { $0.remoteID }
        XCTAssertEqual(fetchedSlates.count, 2)
        XCTAssertEqual(Set(fetchedSlateIDs), ["slate-1", "slate-2"])

        // 3. Old recommendations should be deleted
        let fetchedRecommendations = try space.fetchRecommendations()
        XCTAssertEqual(fetchedRecommendations.count, 3)
        let fetchedRecommendationIDs = fetchedRecommendations.map { $0.remoteID }
        XCTAssertFalse(fetchedRecommendationIDs.contains("slate-1-recommendation-1-seed"))

        // 4. Old items should be removed
        let items = try space.fetchItems()
        XCTAssertEqual(items.count, 3)
        let itemIDs = items.map { $0.remoteID }
        XCTAssertEqual(Set(itemIDs), ["item-1", "item-2", "item-3"])
    }

    @MainActor
    func test_fetchSlateLineup_existingSlateLineup_hasSavedItems_keepsItems() async throws {
        apollo.stubFetch(toReturnFixtureNamed: "slates", asResultType: GetSlateLineupQuery.self)

        let item = space.buildItem(remoteID: "item-1-seed")
        space.buildSavedItem(item: item)
        let recommendation = space.buildRecommendation(remoteID: "slate-1-recommendation-seed", item: item)
        let slate = space.buildSlate(remoteID: "slate-1-seed", recommendations: [recommendation])
        space.buildSlateLineup(slates: [slate])
        try self.space.save()

        let service = subject()
        try await service.fetchSlateLineup("slate-lineup-identifier")

        let items = try space.fetchItems()
        XCTAssertEqual(items.count, 4)
    }

    @MainActor
    func test_fetchSlateLineup_existingItem_updatesExistingItem() async throws {
        apollo.stubFetch(toReturnFixtureNamed: "slates", asResultType: GetSlateLineupQuery.self)

        // fetchSlateLineup "cleans" all unsaved items before fetching,
        // so we have to fake a saved item for the item to update
        let item = space.buildItem(title: "Item 1 Seed", givenURL: "https://given.example.com/slate-1-rec-1")
        space.buildSavedItem(item: item)
        try self.space.save()

        let service = subject()
        try await service.fetchSlateLineup("slate-lineup-identifier")

        XCTAssertEqual(item.title, "Slate 1, Recommendation 1")
    }
}
