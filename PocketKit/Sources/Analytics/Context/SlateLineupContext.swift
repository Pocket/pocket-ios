// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct SlateLineupContext: Context {
    public static let schema = "iglu:com.pocket/slate_lineup/jsonschema/1-0-0"

    let id: String
    let requestID: String
    let experiment: String

    public init(id: String, requestID: String, experiment: String) {
        self.id = id
        self.requestID = requestID
        self.experiment = experiment
    }
}

private extension SlateLineupContext {
    enum CodingKeys: String, CodingKey {
        case id = "slate_lineup_id"
        case requestID = "request_id"
        case experiment
    }
}
