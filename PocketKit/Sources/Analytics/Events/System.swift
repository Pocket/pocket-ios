// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/**
 * Event created by a background task
 */
public struct System: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/system_log/jsonschema/1-0-0"

    let type: System.SystemLogType
    let source: MigrationSource

    public init(type: SystemLogType, source: MigrationSource) {
        self.type = type
        self.source = source
    }

    public var description: String {
        switch type {
        case .userMigration(let userMigrationState):
            return userMigrationState.id(source)
        }
    }

    public var value: String? {
        switch type {
        case .userMigration(let userMigrationState):
            return userMigrationState.value(source)
        }
    }

    public func toSelfDescribing() -> SelfDescribing {
        var payload = [
            "identifier": NSString(string: self.description),
        ]

        if let value = value {
            payload["value"] = NSString(string: value)
        }

        return SelfDescribing(schema: System.schema, payload: payload)
    }
}

extension System {
    public enum SystemLogType {
        case userMigration(UserMigrationState)
    }

    public enum UserMigrationState {
        case started
        case succeeded
        case failed(Error?)

        func id(_ source: MigrationSource) -> String {
            switch self {
            case .started:
                return "ios.\(source).migration.to8.start"
            case .succeeded:
                return "ios.\(source).migration.to8.succeeded"
            case UserMigrationState.failed(let error):
                if error == nil {
                    return "ios.\(source).migration.to8.failed"
                }
                return "ios.\(source).migration.to8.failedWithError"
            }
        }

        func value(_ source: MigrationSource) -> String? {
            switch self {
            case .started, .succeeded:
                return nil
            case UserMigrationState.failed(let error):
                return error?.localizedDescription
            }
        }
    }
}
