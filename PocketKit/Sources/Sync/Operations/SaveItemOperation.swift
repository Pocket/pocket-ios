import Foundation
import Apollo
import CoreData
import PocketGraph

class SaveItemOperation: SyncOperation {
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
    }

    func execute() async -> SyncOperationResult {
        let input = SavedItemUpsertInput(url: url.absoluteString)
        let mutation = SaveItemMutation(input: input)

        do {
            let result = try await apollo.perform(mutation: mutation)
            await handle(result: result)
            return .success
        } catch {
            switch error {
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .retry(error)
                default:
                    return .failure(error)
                }
            case is URLSessionClient.URLSessionClientError:
                // An error occurred with the client-side networking stack
                // either the request timed out or it couldn't be sent for some other reason
                // retry
                return .retry(error)
            default:
                events.send(.error(error))
                return .failure(error)
            }
        }
    }

    @MainActor
    private func handle(result: GraphQLResult<SaveItemMutation.Data>) {
        guard let remote = result.data?.upsertSavedItem.fragments.savedItemParts,
              let savedItem: SavedItem = space.context.object(with: managedItemID) as? SavedItem else {
            return
        }

        savedItem.update(from: remote, with: space)

        do {
            try space.save()
        } catch {
            events.send(.error(error))
        }
    }
}
