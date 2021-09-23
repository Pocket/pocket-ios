import Apollo
import Foundation

protocol SlateService {
    func fetchSlates() async throws -> [Slate]
}

class APISlateService: SlateService {
    static let lineupID = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"

    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetchSlates() async throws -> [Slate] {
        try await apollo
            .fetch(query: GetSlateLineupQuery(lineupID: Self.lineupID, maxRecommendations: 5))
            .data?.getSlateLineup?.slates.map(Slate.init) ?? []
    }
}
