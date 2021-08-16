import Foundation
import Apollo
import Combine


protocol SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int
    ) -> Operation

    func favoriteItem(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) -> Operation

    func unfavoriteItem(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) -> Operation

    func deleteItem(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
        itemID: String
    ) -> Operation
}

class OperationFactory: SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int
    ) -> Operation {
        return FetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: events,
            maxItems: maxItems
        )
    }

    func favoriteItem(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) -> Operation {
        FavoriteItem(
            space: space,
            apollo: apollo,
            itemID: itemID,
            events: events
        )
    }

    func unfavoriteItem(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) -> Operation {
        UnfavoriteItem(
            space: space,
            apollo: apollo,
            itemID: itemID,
            events: events
        )
    }

    func deleteItem(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
        itemID: String
    ) -> Operation {
        DeleteItem(apollo: apollo, events: events, itemID: itemID)
    }
}
