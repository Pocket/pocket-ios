// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct RecommendationContext: Context {
    public static let schema = "iglu:com.pocket/recommendation/jsonschema/1-0-0"

    let id: String
    let index: UIIndex

    public init(id: String, index: UIIndex) {
        self.id = id
        self.index = index
    }
}

private extension RecommendationContext {
    enum CodingKeys: String, CodingKey {
        case id = "recommendation_id"
        case index
    }
}
