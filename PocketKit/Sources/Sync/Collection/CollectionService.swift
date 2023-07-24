// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import Foundation
import PocketGraph
import SharedPocketKit

protocol CollectionService {
    func fetchCollection(by identifier: String) async throws -> CollectionModel
}

// TODO: Refine error handling
public enum CollectionServiceError: Error {
    case anError
}

class APICollectionService: CollectionService {
    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    func fetchCollection(by slug: String) async throws -> CollectionModel {
        let query = GetCollectionBySlugQuery(slug: slug)

        guard let remote = try await apollo.fetch(query: query).data?.collection else {
            Log.capture(message: "Error loading collection")
            throw CollectionServiceError.anError
        }

        // TODO: Add Core data changes and publish changes instead of returning model
        return CollectionModel(
            title: remote.title,
            authors: remote.authors.compactMap { $0.name },
            intro: remote.intro,
            stories: remote.stories.compactMap {
                Story(title: $0.title, publisher: $0.publisher, imageURL: $0.imageUrl, excerpt: $0.excerpt, timeToRead: $0.item?.timeToRead, isCollection: $0.item?.collection?.slug != nil)
            }
        )
    }
}
