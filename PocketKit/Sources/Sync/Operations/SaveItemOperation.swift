// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import CoreData
import PocketGraph

class SaveItemOperation: SyncOperation {
    private let managedItemID: NSManagedObjectID
    private let url: String
    private let events: SyncEvents
    private let apollo: ApolloClientProtocol
    private let space: Space

    init(
        managedItemID: NSManagedObjectID,
        url: String,
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

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        let input = SavedItemUpsertInput(url: url)
        let mutation = SaveItemMutation(input: input)

        do {
            let result = try await apollo.perform(mutation: mutation)
            handle(result: result)
            return .success
        } catch {
            switch error {
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .failure(error)
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

    private func handle(result: GraphQLResult<SaveItemMutation.Data>) {
        space.performAndWait {
            guard let remote = result.data?.upsertSavedItem.fragments.savedItemParts,
                  let savedItem: CDSavedItem = space.backgroundContext.object(with: managedItemID) as? CDSavedItem else {
                return
            }

            savedItem.update(from: remote, with: space)
        }

        do {
            try space.save()
        } catch {
            events.send(.error(error))
        }
    }
}
