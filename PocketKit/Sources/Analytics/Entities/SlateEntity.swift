// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct SlateEntity: Entity {
    public static let schema = "iglu:com.pocket/slate/jsonschema/1-0-0"

    let id: String
    let requestID: String
    let experiment: String
    let index: Int
    let displayName: String?
    let description: String?

    public init(id: String, requestID: String, experiment: String, index: Int, displayName: String? = nil, description: String? = nil) {
        self.id = id
        self.requestID = requestID
        self.experiment = experiment
        self.index = index
        self.displayName = displayName
        self.description = description
    }
}

private extension SlateEntity {
    enum CodingKeys: String, CodingKey {
        case id = "slate_id"
        case requestID = "request_id"
        case experiment
        case index
        case displayName = "display_name"
        case description
    }
}
