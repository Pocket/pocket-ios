import Apollo
import Foundation

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
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: 5)

        guard let remote = try await apollo.fetch(query: query).data?.getSlateLineup else {
            return
        }

        if let existingSlateLineup = try space.fetchSlateLineup(byRemoteID: remote.id) {
            space.delete(existingSlateLineup)
        }

        try space.deleteUnsavedItems()

        let slateLineup: SlateLineup = space.new()
        slateLineup.update(from: remote, in: space)

        try self.space.save()
    }

    func fetchSlate(_ slateID: String) async throws {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: 25)

        guard let remote = try await apollo.fetch(query: query).data?.getSlate?.fragments.slateParts else {
            return
        }

        let unsavedItems = try space.fetchUnsavedItems()
        unsavedItems.forEach {
            space.delete($0)
        }

        let slate: Slate = try space.fetchOrCreateSlate(byRemoteID: remote.id)
        slate.update(from: remote, in: space)

        try self.space.save()
    }
}
