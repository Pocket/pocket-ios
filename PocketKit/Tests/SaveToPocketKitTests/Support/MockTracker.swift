// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics

class MockTracker: Tracker {
    struct TrackCall {
        let event: OldEvent
        let contexts: [OldEntity]?
    }

    private var persistentContexts: [OldEntity] = []

    private(set) var trackCalls = Calls<TrackCall>()

    func addPersistentContext(_ context: OldEntity) {
    }

    func resetPersistentContexts(_ contexts: [OldEntity]) {
        persistentContexts = []
    }

    func track<T: OldEvent>(event: T, _ contexts: [OldEntity]?) {
        trackCalls.add(TrackCall(event: event, contexts: contexts))
    }

    func childTracker(with contexts: [OldEntity]) -> Tracker {
        NoopTracker()
    }
}

struct MockEvent: OldEvent {
    static var schema = "mock-event"

    let value: Int
}

struct MockContext: OldEntity {
    static var schema = "mock-context"

    let value: String
}
