import Apollo
import Foundation

protocol SlateService {
    func fetchSlates() async throws -> [Slate]
    func fetchSlate(_ slateID: String) async throws -> Slate?
}

class APISlateService: SlateService {
    static let lineupID = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"

    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetchSlates() async throws -> [Slate] {
        let query = GetSlateLineupQuery(lineupID: Self.lineupID, maxRecommendations: 5)

        return try await apollo
            .fetch(query: query)
            .data?.getSlateLineup?.slates.map { slate in
                Slate(remote: slate.fragments.slateParts)
            } ?? []
    }

    func fetchSlate(_ slateID: String) async throws -> Slate? {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: 25)
        let remote = try await apollo.fetch(query: query).data?.getSlate

        return (remote?.fragments.slateParts).flatMap(Slate.init)
    }
}
