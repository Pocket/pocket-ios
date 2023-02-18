// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics

class MockTracker: Tracker {
    struct OldTrackCall {
        let event: OldEvent
        let contexts: [Context]?
    }

    struct TrackCall {
        let event: Event
    }

    private var persistentContexts: [Context] = []

    private(set) var oldTrackCalls = Calls<OldTrackCall>()
    private(set) var trackCalls = Calls<TrackCall>()

    func addPersistentContext(_ context: Context) {
    }

    func resetPersistentContexts(_ contexts: [Context]) {
        persistentContexts = []
    }

    func track<T: OldEvent>(event: T, _ contexts: [Context]?) {
        oldTrackCalls.add(OldTrackCall(event: event, contexts: contexts))
    }

    public func track(event: Event, filename: String, line: Int, column: Int, funcName: String) {
        trackCalls.add(TrackCall(event: event))
    }

    func childTracker(with contexts: [Context]) -> Tracker {
        NoopTracker()
    }
}

struct MockEvent: OldEvent {
    static var schema = "mock-event"

    let value: Int
}

struct MockContext: Context {
    static var schema = "mock-context"

    let value: String
}
