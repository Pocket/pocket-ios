// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import Foundation
import PocketGraph
import SharedPocketKit

protocol SlateService {
    func fetchSlateLineup(_ identifier: String) async throws
}

class APISlateService: SlateService {
    private let apollo: ApolloClientProtocol
    private let space: Space

    init(
        apollo: ApolloClientProtocol,
        space: Space
    ) {
        self.apollo = apollo
        self.space = space
    }

    func fetchSlateLineup(_ identifier: String) async throws {
        let query = GetSlateLineupQuery(lineupID: identifier, maxRecommendations: SyncConstants.Home.recomendationsPerSlateFromSlateLineup)

        guard let remote = try await apollo.fetch(query: query).data?.getSlateLineup else {
            Log.capture(message: "Error loading slate lineup")
            return
        }
        try space.updateLineup(from: remote)
    }
}
