import Apollo
import Foundation
import PocketGraph

protocol SlateService {
    func fetchSlateLineup(_ identifier: String) async throws
    func fetchSlate(_ slateID: String) async throws
}

class APISlateService: SlateService {
    private let apollo: ApolloClientProtocol
    private let space: Space

    init(
        apollo: ApolloClientProtocol,
        space: Space
    ) {
        self.apollo = apollo
        self.space = space
    }

    func fetchSlateLineup(_ identifier: String) async throws {
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: SyncConstants.Home.recomendationsPerSlateFromSlateLineup)

        guard let remote = try await apollo.fetch(query: query).data?.getSlateLineup else {
            Log.capture(message: "Error loading slate lineup")
            return
        }
        try space.updateLineup(from: remote)
    }

    func fetchSlate(_ slateID: String) async throws {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: SyncConstants.Home.recomendationsPerSlateDetail)

        guard let remote = try await apollo.fetch(query: query)
            .data?.getSlate.fragments.slateParts else {
            return
        }
        try space.updateSlate(from: remote)
    }
}
