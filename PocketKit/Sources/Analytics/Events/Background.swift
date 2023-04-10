// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/**
 * Event created by a background task
 */
public struct Background: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/content_open/jsonschema/1-0-0" // TODO

    let type: Background.BackgroundType
    let source: MigrationSource

    let extraEntities: [Entity]

    public init(type: BackgroundType, source: MigrationSource, extraEntities: [Entity] = []) {
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
        let base = SelfDescribing(schema: Background.schema, payload: [
            "type": NSString(string: "\(self.type)"),
            "id": NSString(string: self.description)
        ])
        extraEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }

        return base
    }
}

extension Background {
    public enum BackgroundType {
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
                guard let error else {
                    return "ios.migration.to8.failed"
                }
                return "ios.migration.to8.failedWithError"
            }
        }
    }
}
