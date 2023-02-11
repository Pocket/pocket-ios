// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

class LinkedTracker: Tracker {
    private let parent: Tracker
    private let contexts: [OldEntity]

    init(parent: Tracker, contexts: [OldEntity]) {
        self.parent = parent
        self.contexts = contexts
    }

    func addPersistentContext(_ context: OldEntity) {
        parent.addPersistentContext(context)
    }

    func track<T>(event: T, _ contexts: [OldEntity]?) where T: OldEvent {
        let additional = contexts ?? []
        parent.track(event: event, self.contexts + additional)
    }

    func track(event: Event) {
        parent.track(event: event)
    }

    func childTracker(with contexts: [OldEntity]) -> Tracker {
        LinkedTracker(parent: self, contexts: contexts)
    }

    func resetPersistentContexts(_ contexts: [OldEntity]) {
        parent.resetPersistentContexts(contexts)
    }
}
