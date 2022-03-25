import Foundation
import Apollo
import Sync


class PocketSaveService: SaveService {
    private let apollo: ApolloClientProtocol
    private let backgroundActivityPerformer: ExpiringActivityPerformer

    init(apollo: ApolloClientProtocol, backgroundActivityPerformer: ExpiringActivityPerformer) {
        self.apollo = apollo
        self.backgroundActivityPerformer = backgroundActivityPerformer
    }

    func save(url: URL) {
        backgroundActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { expiring in
            if !expiring {
                let mutation = SaveItemMutation(input: SavedItemUpsertInput(url: url.absoluteString))
                Task {
                    _ = try? await self.apollo.perform(mutation: mutation)
                }
            }
        }
    }
}
