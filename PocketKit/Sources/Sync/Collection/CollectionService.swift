// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import Foundation
import PocketGraph
import SharedPocketKit

protocol CollectionService {
    func fetchCollection(by identifier: String) async throws
}

enum CollectionServiceError: Error {
    case nullCollection
}

class APICollectionService: CollectionService {
    private let apollo: ApolloClientProtocol
    private let space: Space

    init(apollo: ApolloClientProtocol, space: Space) {
        self.apollo = apollo
        self.space = space
    }

    func fetchCollection(by slug: String) async throws {
        let query = GetCollectionBySlugQuery(slug: slug)

        guard let remote = try await apollo.fetch(query: query).data?.collection else {
            Log.capture(message: "CollectionService Error - the request returned a null collection")
            throw CollectionServiceError.nullCollection
        }
        try space.updateCollection(from: remote)
    }
}
