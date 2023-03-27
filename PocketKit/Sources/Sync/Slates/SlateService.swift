import Apollo
import Foundation
import CoreData
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

        try await handle(remote: remote)
    }

    func fetchSlate(_ slateID: String) async throws {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: SyncConstants.Home.recomendationsPerSlateDetail)

        guard let remote = try await apollo.fetch(query: query)
            .data?.getSlate.fragments.slateParts else {
            return
        }

        try await handle(remote: remote)
    }

    private func handle(remote: GetSlateLineupQuery.Data.GetSlateLineup) throws {
        space.performAndWait {
            let lineup = (try? space.fetchSlateLineup(byRemoteID: remote.id)) ?? SlateLineup(context: space.backgroundContext, remoteID: remote.id, expermimentID: remote.experimentId, requestID: remote.requestId)
            lineup.update(from: remote, in: space)
        }

        try space.save()
        try space.batchDeleteOrphanedSlates()
        try space.batchDeleteOrphanedItems()
    }

    private func handle(remote: SlateParts) throws {
        space.performAndWait {
            let slate = (try? space.fetchSlate(byRemoteID: remote.id)) ?? Slate(context: space.backgroundContext, remoteID: remote.id, expermimentID: remote.experimentId, requestID: remote.requestId)
            slate.update(from: remote, in: space)
        }

        try space.save()
    }
}
