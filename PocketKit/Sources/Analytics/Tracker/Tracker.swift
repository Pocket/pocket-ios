// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker

public protocol Tracker {
    func addPersistentContext(_ context: Context)
    func addPersistentEntity(_ entity: Entity)
    @available(*, deprecated, message: "Use track with an explict Event defintion")
    func track<T: OldEvent>(event: T, _ contexts: [Context]?)
    func track(event: Event)
    @available(*, deprecated, message: "No need to longer use a child tracker")
    func childTracker(with contexts: [Context]) -> Tracker
    func resetPersistentContexts(_ contexts: [Context])
    func resetPersistentEntities(_ entities: [Entity])
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [Context]) {
        contexts.forEach { addPersistentContext($0) }
    }

    func addPersistentContexts(_ entities: [Entity]) {
        entities.forEach { addPersistentEntity($0) }
    }

    func childTracker(hosting context: UIContext) -> Tracker {
        childTracker(with: [context])
    }
}
