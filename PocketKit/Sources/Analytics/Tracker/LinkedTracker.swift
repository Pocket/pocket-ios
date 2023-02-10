// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

class LinkedTracker: Tracker {
    private let parent: Tracker
    private let contexts: [Entity]

    init(parent: Tracker, contexts: [Entity]) {
        self.parent = parent
        self.contexts = contexts
    }

    func addPersistentContext(_ context: Entity) {
        parent.addPersistentContext(context)
    }

    func track<T>(event: T, _ contexts: [Entity]?) where T: Event {
        let additional = contexts ?? []
        parent.track(event: event, self.contexts + additional)
    }

    func track(event: AppEvent) {
        track(event: event.event, event.entities)
    }

    func childTracker(with contexts: [Entity]) -> Tracker {
        LinkedTracker(parent: self, contexts: contexts)
    }

    func resetPersistentContexts(_ contexts: [Entity]) {
        parent.resetPersistentContexts(contexts)
    }
}
