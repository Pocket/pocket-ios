import Apollo
import Foundation

protocol SlateService {
    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup?
    func fetchSlate(_ slateID: String) async throws -> Slate?
}

class APISlateService: SlateService {
    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: 5)
        
        return try await apollo
            .fetch(query: query)
            .data?.getSlateLineup
            .flatMap { $0 }
            .map(SlateLineup.init)
    }

    func fetchSlate(_ slateID: String) async throws -> Slate? {
        let query = GetSlateQuery(slateID: slateID, recommendationCount: 25)
        let remote = try await apollo.fetch(query: query).data?.getSlate

        return (remote?.fragments.slateParts).flatMap(Slate.init)
    }
}
