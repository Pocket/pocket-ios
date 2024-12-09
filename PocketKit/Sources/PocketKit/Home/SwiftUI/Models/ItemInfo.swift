// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Set of info to send along actions for analytics purposes
struct ItemInfo {
    let type: CardType
    let url: String
    let index: Int
    let recommendationID: String?
    let externalDestination: Bool

    init(type: CardType, url: String, index: Int = 0, recommendationID: String? = nil, externalDestination: Bool = false) {
        self.type = type
        self.url = url
        self.index = index
        self.recommendationID = recommendationID
        self.externalDestination = externalDestination
    }
}

struct SlateInfo: Codable, Equatable, Hashable {
    let slateId: String
    let slateRequestId: String
    let slateExperimentId: String
    let slateIndex: Int
    let slateLineupId: String
    let slateLineupRequestId: String
    let slateLineupExperimentId: String
}
