// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct OldContentOpenEvent: OldEvent {
    public static let schema = "iglu:com.pocket/content_open/jsonschema/1-0-0"

    let destination: Destination
    let trigger: Trigger

    public init(destination: Destination = .internal, trigger: Trigger = .click) {
        self.destination = destination
        self.trigger = trigger
    }
}

extension OldContentOpenEvent {
    public enum Destination: String, Encodable {
        case `internal`
        case external
    }

    public enum Trigger: String, Encodable {
        case click
        case auto
    }
}
