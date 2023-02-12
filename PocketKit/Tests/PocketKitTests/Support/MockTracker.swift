// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics

class MockTracker: Tracker {
    struct TrackCall {
        let event: Event
        let contexts: [Entity]?
    }

    private var persistentContexts: [Entity] = []

    private(set) var trackCalls = Calls<TrackCall>()

    func addPersistentContext(_ context: Entity) {
    }

    func resetPersistentContexts(_ contexts: [Entity]) {
        persistentContexts = []
    }

    func track<T: Event>(event: T, _ contexts: [Entity]?) {
        trackCalls.add(TrackCall(event: event, contexts: contexts))
    }

    func childTracker(with contexts: [Entity]) -> Tracker {
        NoopTracker()
    }
}

struct MockEvent: Event {
    static var schema = "mock-event"

    let value: Int
}

struct MockContext: Entity {
    static var schema = "mock-context"

    let value: String
}
