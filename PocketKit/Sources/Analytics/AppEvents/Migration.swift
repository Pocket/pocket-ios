// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

/// Used to track migration event source
public extension Events {
    struct Migration {}
}

public extension Events.Migration {
    /**
     Fired when the user begins migrating from V7 to V8
     */
    static func MigrationTo_v8DidBegin(source: System.EventSource) -> System {
        return System(type: .userMigration(.started), source: source)
    }

    /**
     Fired when the user succeeds migrating from V7 to V8
     */
    static func MigrationTo_v8DidSucceed(source: System.EventSource) -> System {
        return System(type: .userMigration(.succeeded), source: source)
    }

    /**
     Fired when the user fails migrating from V7 to V8. Optional error
     */
    static func MigrationTo_v8DidFail(with error: Error?, source: System.EventSource) -> System {
        return System(type: .userMigration(.failed(error)), source: source)
    }
}
