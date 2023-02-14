import Apollo
import Foundation
import CoreData
import PocketGraph

protocol SlateService {
    func fetchSlateLineup(_ identifier: String) async throws
    func fetchSlate(_ slateID: String, slateLineup: SlateLineup) async throws
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
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: 5)

        guard let remote = try await apollo.fetch(query: query).data?.getSlateLineup else {
            return
        }

        try await handle(remote: remote)
    }

    func fetchSlate(_ slateID: String, slateLineup: SlateLineup) async throws {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: 25)

        guard let remote = try await apollo.fetch(query: query)
            .data?.getSlate.fragments.slateParts else {
            return
        }

        try await handle(remote: remote, slateLineup: slateLineup)
    }

    @MainActor
    private func handle(remote: GetSlateLineupQuery.Data.GetSlateLineup) throws {
        let lineup = (try? space.fetchSlateLineup(byRemoteID: remote.id)) ??
        SlateLineup(
            context: space.context,
            remoteID: remote.id,
            expermimentID: remote.experimentId,
            requestID: remote.requestId
        )
        lineup.update(from: remote, in: space)

        try space.save()
        try space.batchDeleteOrphanedSlates()
        try space.batchDeleteOrphanedItems()
    }

    @MainActor
    private func handle(remote: SlateParts, slateLineup: SlateLineup) throws {
        let slate = (try? space.fetchSlate(byRemoteID: remote.id)) ??
        Slate(
            context: space.context,
            remoteID: remote.id,
            expermimentID: remote.experimentId,
            requestID: remote.requestId,
            slateLineup: slateLineup
        )
        slate.update(from: remote, in: space)

        try space.save()
    }
}
