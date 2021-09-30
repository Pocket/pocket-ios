import Foundation
import Apollo
import CoreData


class SaveItemOperation: AsyncOperation {
    private let managedItemID: NSManagedObjectID
    private let url: URL
    private let events: SyncEvents
    private let apollo: ApolloClientProtocol
    private let space: Space

    init(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) {
        self.managedItemID = managedItemID
        self.url = url
        self.events = events
        self.apollo = apollo
        self.space = space

        super.init()
    }

    override func main() {
        let input = SavedItemUpsertInput(url: url.absoluteString)
        let mutation = SaveItemMutation(input: input)

        Task {
            do {
                let result = try await apollo.perform(mutation: mutation)
                handle(result: result)
            } catch {
                events.send(.error(error))
            }

            finishOperation()
        }
    }

    private func handle(result: GraphQLResult<SaveItemMutation.Data>) {
        guard let remote = result.data?.upsertSavedItem.fragments.savedItemParts,
              let savedItem: SavedItem = space.context.object(with: managedItemID) as? SavedItem else {
            return
        }

        savedItem.update(from: remote)

        do {
            try space.save()
        } catch {
            events.send(.error(error))
        }
    }
}
