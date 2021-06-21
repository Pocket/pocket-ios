// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine


public class Source {
    private let space: Space
    private let apollo: ApolloClientProtocol
    private let errorSubject: PassthroughSubject<Error, Never>?
    private let syncQ: OperationQueue

    public var managedObjectContext: NSManagedObjectContext {
        space.context
    }

    public convenience init(
        accessTokenProvider: AccessTokenProvider,
        container: NSPersistentContainer = .createDefault(),
        errorSubject: PassthroughSubject<Error, Never>? = nil
    ) {
        let apollo = ApolloClient.createDefault(
            accessTokenProvider: accessTokenProvider
        )

        self.init(
            apollo: apollo,
            container: container,
            errorSubject: errorSubject
        )
    }
    
    public required init(
        apollo: ApolloClientProtocol,
        container: NSPersistentContainer = .createDefault(),
        errorSubject: PassthroughSubject<Error, Never>? = nil
    ) {
        self.apollo = apollo
        self.space = Space(container: container)
        self.errorSubject = errorSubject
        self.syncQ = OperationQueue()
    }

    public func refresh(token: String, maxItems: Int = 400) {
        syncQ.addOperation(FetchPageOfItems(
            apollo: apollo,
            space: space,
            query: UserByTokenQuery(token: token),
            maxItems: maxItems,
            nextPageQueue: syncQ,
            errorSubject: errorSubject
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
    private let errorSubject: PassthroughSubject<Error, Never>?
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
        errorSubject: PassthroughSubject<Error, Never>?
    ) {
        self.apollo = apollo
        self.space = space
        self.query = query
        self.maxItems = maxItems
        self.nextPageQueue = nextPageQueue
        self.errorSubject = errorSubject

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
            errorSubject?.send(error)
        case .success(let data):
            do {
                try updateItems(from: data)
            } catch {
                errorSubject?.send(error)
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
                errorSubject: errorSubject
            )

            nextPageQueue?.addOperation(op)
        } else {
            try space.save()
        }
    }
}
