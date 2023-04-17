// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/**
 * Event created by a background task
 */
public struct System: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/system_event/jsonschema/1-0-0"

    let type: System.SystemEventType
    let source: MigrationSource

    let extraEntities: [Entity]

    public init(type: SystemEventType, source: MigrationSource, extraEntities: [Entity] = []) {
        self.type = type
        self.source = source
        self.extraEntities = extraEntities
    }

    public var description: String {
        switch type {
        case .userMigration(let userMigrationState):
            return userMigrationState.id()
        }
    }

    public func toSelfDescribing() -> SelfDescribing {
        let base = SelfDescribing(schema: System.schema, payload: [
            "identifier": NSString(string: self.description),
        ])

        return base
    }
}

extension System {
    public enum SystemEventType {
        case userMigration(UserMigrationState)
    }

    public enum UserMigrationState {
        case started
        case succeeded
        case failed(Error?)

        func id() -> String {
            switch self {
            case .started:
                return "ios.migration.to8.start"
            case .succeeded:
                return "ios.migration.to8.succeeded"
            case UserMigrationState.failed(let error):
                if error == nil {
                    return "ios.migration.to8.failed"
                }
                return "ios.migration.to8.failedWithError"
            }
        }
    }
}
