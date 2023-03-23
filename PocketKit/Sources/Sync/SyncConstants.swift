// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct SyncConstants {
    struct Saves {
        /// How many saves we load when a user logs in. As they save and use pocket they may accumilate more, but we only download the amount of latest saves here to start.
        static let firstLoadMaxCount = 500

        /// How many saves we should load on the first login request for saves, we use a small value here so the user immediately sees content.
        static let initalPageSize = 15

        /// How many saves to load per subsequent page until we hit our load count.
        static let pageSize = 30
    }

    struct Archive {
        /// How many archives we load when a user logs in. As they save and use pocket they may accumilate more, but we only download the amount of latest archives here to start.
        static let firstLoadMaxCount = 500

        /// How many archives we should load on the first login request for archives, we use a small value here so the user immediately sees content.
        static let initalPageSize = 15

        /// How many archives to load per subsequent page until we hit our load count.
        static let pageSize = 30
    }

    struct Home {
        /// How many recomendations to pull in when we load them via getSlateLineup (ie. Home)
        static let recomendationsPerSlateFromSlateLineup = 15

        /// How many recomendations to pull in when we load them via getSlate (ie. a detail view)
        static let recomendationsPerSlateDetail = 15
    }
}
