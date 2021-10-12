// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker


public protocol SnowplowEvent: Encodable {
    static var schema: String { get }
}

public protocol SnowplowContext: Encodable {
    static var schema: String { get }
}

extension SnowplowContext {
    var jsonEncoded: Data? {
        return try? JSONEncoder().encode(self)
    }
}

public protocol SnowplowTracking {
    func track(event: SelfDescribing)
}
