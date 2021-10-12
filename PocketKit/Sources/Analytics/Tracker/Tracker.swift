// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SnowplowTracker


public protocol Tracker {
    func addPersistentContext(_ context: SnowplowContext)
    func track<T: SnowplowEvent>(event: T, _ contexts: [SnowplowContext]?)
    func childTracker(with contexts: [SnowplowContext]) -> Tracker
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [SnowplowContext]) {
        contexts.forEach { addPersistentContext($0) }
    }
    
    func childTracker(hosting context: UIContext) -> Tracker {
        childTracker(with: [context])
    }
}
