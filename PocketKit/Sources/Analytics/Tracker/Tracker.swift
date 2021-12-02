// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker


public protocol Tracker {
    func addPersistentContext(_ context: Context)
    func track<T: Event>(event: T, _ contexts: [Context]?)
    func childTracker(with contexts: [Context]) -> Tracker
    func resetPersistentContexts(_ contexts: [Context])
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [Context]) {
        contexts.forEach { addPersistentContext($0) }
    }
    
    func childTracker(hosting context: UIContext) -> Tracker {
        childTracker(with: [context])
    }
}
