// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine


public typealias SyncEvents = PassthroughSubject<SyncEvent, Never>

public class Source {
    public let syncEvents: SyncEvents = PassthroughSubject()

    private let space: Space
    private let apollo: ApolloClientProtocol
    private let lastRefresh: LastRefresh
    private let tokenProvider: AccessTokenProvider
    private let slateService: SlateService

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
        sessionProvider: SessionProvider,
        accessTokenProvider: AccessTokenProvider,
        consumerKey: String,
        defaults: UserDefaults
    ) {
        let apollo = ApolloClient.createDefault(
            sessionProvider: sessionProvider,
            accessTokenProvider: accessTokenProvider,
            consumerKey: consumerKey
        )

        self.init(
            space: Space(container: .createDefault()),
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            accessTokenProvider: accessTokenProvider,
            slateService: APISlateService(apollo: apollo)
        )
    }

    init(
        space: Space,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory,
        lastRefresh: LastRefresh,
        accessTokenProvider: AccessTokenProvider,
        slateService: SlateService
    ) {
        self.space = space
        self.apollo = apollo
        self.operations = operations
        self.lastRefresh = lastRefresh
        self.tokenProvider = accessTokenProvider
        self.slateService = slateService
    }

    public var mainContext: NSManagedObjectContext {
        space.context
    }

    public func clear() {
        try? space.clear()
    }
}

// MARK: - List items
extension Source {
    public func refresh(maxItems: Int = 400, completion: (() -> ())? = nil) {
        guard let token = tokenProvider.accessToken else {
            completion?()
            return
        }

        let operation = operations.fetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: syncEvents,
            maxItems: maxItems,
            lastRefresh: lastRefresh
        )

        operation.completionBlock = completion
        syncQ.addOperation(operation)
    }

    public func save(recommendation: Slate.Recommendation) {
        guard let url = recommendation.item.resolvedURL ?? recommendation.item.givenURL else {
            return
        }

        let savedItem: SavedItem = space.new()
        savedItem.url = url

        let item: Item = space.new()
        item.remoteID = recommendation.item.id
        item.givenURL = recommendation.item.givenURL
        item.resolvedURL = recommendation.item.resolvedURL
        item.title = recommendation.item.title
        item.language = recommendation.item.language
        item.topImageURL = recommendation.item.topImageURL
        item.timeToRead = recommendation.item.timeToRead.flatMap(Int32.init) ?? 0
        item.particleJSON = recommendation.item.particleJSON
        item.excerpt = recommendation.item.excerpt
        item.domain = recommendation.item.domain
        item.domainMetadata = recommendation.item.domainMetadata.flatMap { remote in
            let domainMeta: DomainMetadata = space.new()
            domainMeta.name = remote.name
            domainMeta.logo = remote.logo

            return domainMeta
        }

        savedItem.item = item
        try? space.save()

        let operation = operations.saveItemOperation(
            managedItemID: savedItem.objectID,
            url: url,
            events: syncEvents,
            apollo: apollo,
            space: space
        )

        syncQ.addOperation(operation)
    }

    public func favorite(item: SavedItem) {
        mutate(item, FavoriteItemMutation.init) { item in
            item.isFavorite = true
        }
    }

    public func unfavorite(item: SavedItem) {
        mutate(item, UnfavoriteItemMutation.init) { item in
            item.isFavorite = false
        }
    }

    public func delete(item: SavedItem) {
        mutate(item, DeleteItemMutation.init) { item in
            space.delete(item)
        }
    }

    public func archive(item: SavedItem) {
        mutate(item, ArchiveItemMutation.init) { item in
            space.delete(item)
        }
    }

    private func mutate<Mutation: GraphQLMutation>(
        _ item: SavedItem,
        _ remoteMutation: (String) -> Mutation,
        localMutation: (SavedItem) -> ()
    ) {
        guard let remoteID = item.remoteID else {
            return
        }

        localMutation(item)
        try? space.save()

        let operation = operations.savedItemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: remoteMutation(remoteID)
        )

        syncQ.addOperation(operation)
    }
}

// MARK: - Slates
extension Source {
    public func fetchSlates() async throws -> [Slate] {
        return try await slateService.fetchSlates()
    }

    public func fetchSlate(_ slateID: String) async throws -> Slate? {
        return try await slateService.fetchSlate(slateID)
    }
}
