// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine
import Network


public typealias SyncEvents = PassthroughSubject<SyncEvent, Never>

public class PocketSource: Source {
    private let _events: SyncEvents = PassthroughSubject()
    public var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    private let space: Space
    private let apollo: ApolloClientProtocol
    private let lastRefresh: LastRefresh
    private let slateService: SlateService
    private let networkMonitor: NetworkPathMonitor
    private let sessionProvider: SessionProvider

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
        sessionProvider: SessionProvider,
        consumerKey: String,
        defaults: UserDefaults
    ) {
        let apollo = ApolloClient.createDefault(
            sessionProvider: sessionProvider,
            consumerKey: consumerKey
        )

        self.init(
            space: Space(container: .createDefault()),
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            slateService: APISlateService(apollo: apollo),
            networkMonitor: NWPathMonitor(),
            sessionProvider: sessionProvider
        )
    }

    init(
        space: Space,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory,
        lastRefresh: LastRefresh,
        slateService: SlateService,
        networkMonitor: NetworkPathMonitor,
        sessionProvider: SessionProvider
    ) {
        self.space = space
        self.apollo = apollo
        self.operations = operations
        self.lastRefresh = lastRefresh
        self.slateService = slateService
        self.networkMonitor = networkMonitor
        self.sessionProvider = sessionProvider

        observeNetworkStatus()
    }

    public var mainContext: NSManagedObjectContext {
        space.context
    }

    public func clear() {
        lastRefresh.reset()
        try? space.clear()
    }

    public func makeItemsController() -> SavedItemsController {
        FetchedSavedItemsController(
            resultsController: space.makeItemsController()
        )
    }

    public func object<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.object(with: id)
    }

    private func observeNetworkStatus() {
        networkMonitor.start(queue: .main)
        networkMonitor.updateHandler = { [weak self] path in
            switch path.status {
            case .unsatisfied, .requiresConnection:
                self?.syncQ.isSuspended = true
            case .satisfied:
                self?.syncQ.isSuspended = false
            @unknown default:
                self?.syncQ.isSuspended = false
            }
        }
    }
}

// MARK: - List items
extension PocketSource {
    public func refresh(maxItems: Int = 400, completion: (() -> ())? = nil) {
        guard let token = sessionProvider.session?.accessToken else {
            completion?()
            return
        }

        let operation = operations.fetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: _events,
            maxItems: maxItems,
            lastRefresh: lastRefresh
        )

        operation.completionBlock = completion
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
            item.isArchived = true
        }
    }

    public func unarchive(item: SavedItem) {
        mutate(item, UnarchiveItemMutation.init) { item in
            item.isArchived = false
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
            events: _events,
            mutation: remoteMutation(remoteID)
        )

        syncQ.addOperation(operation)
    }
}

// MARK: - Slates
extension PocketSource {
    public func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        return try await slateService.fetchSlateLineup(identifier)
    }

    public func fetchSlate(_ slateID: String) async throws -> Slate? {
        return try await slateService.fetchSlate(slateID)
    }

    public func savedRecommendationsService() -> SavedRecommendationsService {
        SavedRecommendationsService(space: space)
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
        item.excerpt = recommendation.item.excerpt
        item.domain = recommendation.item.domain
        item.article = recommendation.item.article
        item.datePublished = recommendation.item.datePublished

        item.domainMetadata = recommendation.item.domainMetadata.flatMap { remote in
            let domainMeta: DomainMetadata = space.new()
            domainMeta.name = remote.name
            domainMeta.logo = remote.logo

            return domainMeta
        }

        recommendation.item.authors?.forEach { recAuthor in
            let author: Author = space.new()
            author.id = recAuthor.id
            author.name = recAuthor.name
            author.url = recAuthor.url
            item.addToAuthors(author)
        }

        savedItem.item = item
        try? space.save()

        let operation = operations.saveItemOperation(
            managedItemID: savedItem.objectID,
            url: url,
            events: _events,
            apollo: apollo,
            space: space
        )

        syncQ.addOperation(operation)
    }

    public func archive(recommendation: Slate.Recommendation) {
        guard let savedItem = try? space.fetchSavedItem(byRemoteItemID: recommendation.item.id) else {
            return
        }

        archive(item: savedItem)
    }
}

// MARK: - Archived Items
extension PocketSource {
    public func fetchArchivePage(cursor: String?, isFavorite: Bool?) {
        guard let accessToken = sessionProvider.session?.accessToken else {
            return
        }

        let operation = operations.fetchArchivePage(
            apollo: apollo,
            space: space,
            accessToken: accessToken,
            cursor: cursor,
            isFavorite: isFavorite
        )

        operation.completionBlock = { [weak self] in
            self?._events.send(.loadedArchivePage)
        }

        syncQ.addOperation(operation)
    }
}
