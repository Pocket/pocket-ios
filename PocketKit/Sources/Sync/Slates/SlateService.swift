// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import Foundation
import PocketGraph
import SharedPocketKit

protocol SlateService {
    func fetchHomeSlateLineup() async throws
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

    func fetchHomeSlateLineup() async throws {
        let query = HomeSlateLineupQuery(locale: Locale.preferredLanguages.first ?? "en-US")

        guard let remote = try await apollo.fetch(query: query).data?.homeSlateLineup else {
            Log.capture(message: "Error loading unified home lineup")
            return
        }

        try space.updateHomeLineup(from: remote)
    }
}
