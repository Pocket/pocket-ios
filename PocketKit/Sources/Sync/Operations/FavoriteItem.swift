import Foundation
import Apollo
import Combine


class FavoriteItem: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let itemID: String
    private let space: Space
    private let events: PassthroughSubject<SyncEvent, Never>

    init(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) {
        self.space = space
        self.apollo = apollo
        self.itemID = itemID
        self.events = events
    }

    override func main() {
        let mutation = FavoriteItemMutation(itemID: itemID)

        _ = self.apollo.perform(
            mutation: mutation,
            publishResultToStore: false,
            queue: .main
        ) { [weak self] result in
            if case .failure(let error) = result {
                self?.events.send(.error(error))
            }

            self?.finishOperation()
        }
    }
}
