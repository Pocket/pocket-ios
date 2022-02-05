import Apollo


protocol ArchiveService {
    func fetch(accessToken: String?, isFavorite: Bool) async throws -> [ArchivedItem]
    func delete(item: ArchivedItem) async throws
}

class PocketArchiveService: ArchiveService {
    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetch(accessToken: String?, isFavorite: Bool) async throws -> [ArchivedItem] {
        guard let accessToken = accessToken else {
            return []
        }

        let filter = SavedItemsFilter(isFavorite: isFavorite, isArchived: true)
        let query = UserByTokenQuery(token: accessToken, savedItemsFilter: filter)

        return try await apollo.fetch(query: query)
            .data?.userByToken?.savedItems?.edges?
            .compactMap { $0?.node?.fragments.savedItemParts }
            .map(ArchivedItem.init) ?? []
    }

    func delete(item: ArchivedItem) async throws {
        _ = try await apollo.perform(mutation: DeleteItemMutation(itemID: item.remoteID))
    }
}
