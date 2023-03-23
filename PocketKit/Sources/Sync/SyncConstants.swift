// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct SyncConstants {
    public  struct Saves {
        /// How many saves we load when a user logs in. As they save and use pocket they may accumilate more, but we only download the amount of latest saves here to start.
        public static let firstLoadMaxCount = 500

        /// How many saves we should load on the first login request for saves, we use a small value here so the user immediately sees content.
        public  static let initalPageSize = 15

        /// How many saves to load per subsequent page until we hit our load count.
        public  static let pageSize = 30
    }

    public struct Archive {
        /// How many archives we load when a user logs in. As they save and use pocket they may accumilate more, but we only download the amount of latest archives here to start.
        static let firstLoadMaxCount = 500

        /// How many archives we should load on the first login request for archives, we use a small value here so the user immediately sees content.
        static let initalPageSize = 15

        /// How many archives to load per subsequent page until we hit our load count.
        static let pageSize = 30
    }

    public struct Home {
        /// How many recomendations to pull in when we load them via getSlateLineup (ie. Home)
        public static let recomendationsPerSlateFromSlateLineup = 5

        /// How many recomendations to pull in when we load them via getSlate (ie. a detail view)
        public static let recomendationsPerSlateDetail = 25

        /// How many recent saves to show
        public static let recentSaves = 5

        public static let slateLineupIdentifier = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"
    }
}
