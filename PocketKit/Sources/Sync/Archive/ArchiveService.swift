import Apollo


protocol ArchiveService {
    func fetch(accessToken: String?) async throws -> [ArchivedItem]
}

class PocketArchiveService: ArchiveService {
    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetch(accessToken: String?) async throws -> [ArchivedItem] {
        guard let accessToken = accessToken else {
            return []
        }

        let filter = SavedItemsFilter(isArchived: true)
        let query = UserByTokenQuery(token: accessToken, savedItemsFilter: filter)

        return try await apollo.fetch(query: query)
            .data?.userByToken?.savedItems?.edges?
            .compactMap { $0?.node?.fragments.savedItemParts }
            .map(ArchivedItem.init) ?? []
    }
}
