import Foundation
import Apollo
import Combine


class DeleteItem: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let events: PassthroughSubject<SyncEvent, Never>
    private let itemID: String

    init(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
        itemID: String
    ) {
        self.apollo = apollo
        self.events = events
        self.itemID = itemID
    }

    override func main() {
        let mutation = DeleteItemMutation(itemID: itemID)

        _ = apollo.perform(
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
