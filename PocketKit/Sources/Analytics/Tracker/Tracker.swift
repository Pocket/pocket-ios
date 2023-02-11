// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker

public protocol Tracker {
    func addPersistentContext(_ context: OldEntity)
    @available(*, deprecated, message: "Use track with an explict Event defintion")
    func track<T: OldEvent>(event: T, _ contexts: [OldEntity]?)
    func track(event: Event)
    func childTracker(with contexts: [OldEntity]) -> Tracker
    func resetPersistentContexts(_ contexts: [OldEntity])
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [OldEntity]) {
        contexts.forEach { addPersistentContext($0) }
    }

    func childTracker(hosting context: OldUIEntity) -> Tracker {
        childTracker(with: [context])
    }
}
