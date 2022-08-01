import Apollo
import Foundation
import CoreData


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

    @MainActor
    func fetchSlateLineup(_ identifier: String) async throws {
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: 5)

        guard let remote = try await apollo.fetch(query: query).data?.getSlateLineup else {
            return
        }

        let lineup = try space.fetchSlateLineup(byRemoteID: remote.id) ?? space.new()
        lineup.update(from: remote, in: space)

        try space.save()
        try space.batchDeleteOrphanedSlates()
        try space.batchDeleteOrphanedItems()
    }

    @MainActor
    func fetchSlate(_ slateID: String) async throws {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: 25)

        guard let remote = try await apollo.fetch(query: query)
            .data?.getSlate?.fragments.slateParts else {
            return
        }

        let slate: Slate = try space.fetchOrCreateSlate(byRemoteID: remote.id)
        slate.update(from: remote, in: space)

        try self.space.save()
    }
}
