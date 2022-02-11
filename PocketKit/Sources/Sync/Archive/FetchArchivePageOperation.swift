import Apollo


class FetchArchivePageOperation: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let accessToken: String
    private let cursor: String?
    private let isFavorite: Bool?

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        accessToken: String,
        cursor: String?,
        isFavorite: Bool?
    ) {
        self.accessToken = accessToken
        self.apollo = apollo
        self.space = space
        self.cursor = cursor
        self.isFavorite = isFavorite
    }

    override func main() {
        Task { await _main() }
    }

    func _main() async {
        try? await fetch()
        finishOperation()
    }

    func fetch() async throws {
        let query = UserByTokenQuery(
            token: accessToken,
            pagination: PaginationInput(after: cursor, first: 30),
            savedItemsFilter: SavedItemsFilter(isFavorite: isFavorite, isArchived: true)
        )

        let result = try await apollo.fetch(query: query)
        try updateLocalStorage(result: result)
    }

    private func updateLocalStorage(result: GraphQLResult<UserByTokenQuery.Data>) throws {
        guard let edges = result.data?.userByToken?.savedItems?.edges else {
            return
        }

        try space.context.performAndWait {
            for edge in edges {
                guard let edge = edge, let node = edge.node else {
                    return
                }

                let item = try space.fetchOrCreateSavedItem(byRemoteID: node.remoteId)
                item.update(from: edge)

                if item.deletedAt != nil {
                    space.delete(item)
                }
            }

            try space.save()
        }
    }
}
