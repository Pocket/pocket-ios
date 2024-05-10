// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker

public protocol Tracker {
    func addPersistentEntity(_ entity: Entity)
    func track<T: OldEvent>(event: T, _ contexts: [Context]?)
    func track(event: Event, filename: String, line: Int, column: Int, funcName: String)
    func childTracker(with contexts: [Context]) -> Tracker
    func resetPersistentEntities(_ entities: [Entity])
}

public extension Tracker {
    func childTracker(hosting context: UIContext) -> Tracker {
        childTracker(with: [context])
    }

    func track(event: Event, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        track(event: event, filename: filename, line: line, column: column, funcName: funcName)
    }
}
