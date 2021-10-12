// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


class LinkedTracker: Tracker {
    private let parent: Tracker
    private let contexts: [SnowplowContext]
    
    init(parent: Tracker, contexts: [SnowplowContext]) {
        self.parent = parent
        self.contexts = contexts
    }
    
    func addPersistentContext(_ context: SnowplowContext) {
        parent.addPersistentContext(context)
    }
    
    func track<T>(event: T, _ contexts: [SnowplowContext]?) where T : SnowplowEvent {
        let additional = contexts ?? []
        parent.track(event: event, self.contexts + additional)
    }
    
    func childTracker(with contexts: [SnowplowContext]) -> Tracker {
        LinkedTracker(parent: self, contexts: contexts)
    }
}
