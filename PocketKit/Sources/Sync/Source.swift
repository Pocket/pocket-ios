// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine


public enum SyncEvent {
    case finished
    case error(Error)
}

public class Source {
    public let syncEvents: PassthroughSubject<SyncEvent, Never> = PassthroughSubject()

    private let space: Space
    private let apollo: ApolloClientProtocol
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public var managedObjectContext: NSManagedObjectContext {
        space.context
    }

    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        consumerKey: String,
        container: NSPersistentContainer = .createDefault()
    ) {
        let apollo = ApolloClient.createDefault(
            accessTokenProvider: accessTokenProvider,
            consumerKey: consumerKey
        )

        self.init(apollo: apollo, container: container)
    }
    
    public required init(
        apollo: ApolloClientProtocol,
        container: NSPersistentContainer = .createDefault()
    ) {
        self.apollo = apollo
        self.space = Space(container: container)
    }

    public func refresh(token: String, maxItems: Int = 400) {
        syncQ.addOperation(FetchPageOfItems(
            apollo: apollo,
            space: space,
            query: UserByTokenQuery(token: token),
            maxItems: maxItems,
            nextPageQueue: syncQ,
            syncEvents: syncEvents
        ))
    }

    public func clear() {
        try! space.clear()
    }
}

private class FetchPageOfItems: Operation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let query: UserByTokenQuery
    private let maxItems: Int
    private let syncEvents: PassthroughSubject<SyncEvent, Never>
    private weak var nextPageQueue: OperationQueue?

    override var isAsynchronous: Bool {
        true
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            guard newValue != _isFinished else {
                return
            }

            willChangeValue(for: \.isFinished)
            _isFinished = newValue
            didChangeValue(for: \.isFinished)
        }
    }

    private var _isExecuting = false
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            guard newValue != _isExecuting else {
                return
            }

            willChangeValue(for: \.isExecuting)
            _isExecuting = newValue
            didChangeValue(for: \.isExecuting)
        }

    }

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        query: UserByTokenQuery,
        maxItems: Int,
        nextPageQueue: OperationQueue?,
        syncEvents: PassthroughSubject<SyncEvent, Never>
    ) {
        self.apollo = apollo
        self.space = space
        self.query = query
        self.maxItems = maxItems
        self.nextPageQueue = nextPageQueue
        self.syncEvents = syncEvents

        super.init()
    }

    override func main() {
        _ = apollo.fetch(query: query) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<GraphQLResult<UserByTokenQuery.Data>, Error>) {
        switch result {
        case .failure(let error):
            Crashlogger.capture(error: error)
            syncEvents.send(.error(error))
        case .success(let data):
            do {
                try updateItems(from: data)
            } catch {
                Crashlogger.capture(error: error)
                syncEvents.send(.error(error))
            }
        }
        isExecuting = false
        isFinished = true
    }

    func updateItems(from data: GraphQLResult<UserByTokenQuery.Data>) throws {
        guard let edges = data.data?.userByToken?.savedItems?.edges else {
            return
        }

        for edge in edges {
            guard let node = edge?.node else {
                continue
            }

            let item = try space.fetchOrCreateItem(byURLString: node.url)
            item.update(from: node)
        }

        guard let hasNextPage = data.data?.userByToken?.savedItems?.pageInfo.hasNextPage,
              let after = data.data?.userByToken?.savedItems?.edges?.last??.cursor else {
                  try space.save()
                  return
              }

        if self.maxItems > edges.count, hasNextPage {
            let nextPageQuery = UserByTokenQuery(
                token: query.token,
                pagination: PaginationInput(after: after)
            )

            let op = FetchPageOfItems(
                apollo: apollo,
                space: space,
                query: nextPageQuery,
                maxItems: maxItems - edges.count,
                nextPageQueue: nextPageQueue,
                syncEvents: syncEvents
            )
            op.addDependency(self)
            nextPageQueue?.addOperation(op)
        } else {
            let op = FinishSyncOperation(space: space, syncEvents: syncEvents)
            op.addDependency(self)
            nextPageQueue?.addOperation(op)
        }
    }
}

class FinishSyncOperation: Operation {
    let space: Space
    let syncEvents: PassthroughSubject<SyncEvent, Never>

    init(space: Space, syncEvents: PassthroughSubject<SyncEvent, Never>) {
        self.space = space
        self.syncEvents = syncEvents
    }

    override func main() {
        do {
            try space.save()
            syncEvents.send(.finished)
        } catch {
            Crashlogger.capture(error: error)
            syncEvents.send(.error(error))
        }
    }
}
