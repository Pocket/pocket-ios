// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker

public protocol Tracker {
    func addPersistentContext(_ context: Entity)
    func track<T: Event>(event: T, _ contexts: [Entity]?)
    func track(event: AppEvent)
    func childTracker(with contexts: [Entity]) -> Tracker
    func resetPersistentContexts(_ contexts: [Entity])
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [Entity]) {
        contexts.forEach { addPersistentContext($0) }
    }

    func childTracker(hosting context: OldUIEntity) -> Tracker {
        childTracker(with: [context])
    }
}
