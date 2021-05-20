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
    
    public var managedObjectContext: NSManagedObjectContext {
        space.context
    }
    
    public required init(
        apollo: ApolloClientProtocol = ApolloClient.createDefault(),
        container: NSPersistentContainer = .createDefault(),
        errorSubject: PassthroughSubject<Error, Never>? = nil
    ) {
        self.apollo = apollo
        self.space = Space(container: container)
        self.errorSubject = errorSubject
    }

    public func refresh(token: String) {
        let query = UserByTokenQuery(token: token)

        _ = apollo.fetch(query: query) { result in
            switch result {
            case .failure(let error):
                self.errorSubject?.send(error)
            case .success(let data):
                self.updateItems(data)
            }
        }
    }
    
    public func clear() {
        try! space.clear()
    }
}

extension Source {
    private func updateItems(_ data: GraphQLResult<UserByTokenQuery.Data>) {
        guard let nodes = data.data?.userByToken?.userItems?.nodes else {
            return
        }
        
        for node in nodes {
            guard let remoteItem = node?.asyncItem.item else {
                continue
            }
            
            let item = try! space.fetchOrCreateItem(byURL: remoteItem.givenUrl)
            item.update(from: remoteItem)
            
            // This is a workaround to avoid duplicate items being saved.
            // TODO: FIXME.
            try! space.save()
        }
        
        try! space.save()
    }
}
