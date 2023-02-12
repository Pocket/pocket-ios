// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics
import SnowplowTracker

class MockTracker: Analytics.Tracker {
    struct TrackCall {
        let event: Analytics.Event
        let contexts: [Entity]?
    }

    struct AddPersistentCall {
        let context: Entity
    }

    private(set) var trackCalls = Calls<TrackCall>()
    private(set) var addPersistentCalls = Calls<AddPersistentCall>()
    private(set) var clearPersistentContextsCalls = Calls<[Entity]>()

    func addPersistentContext(_ context: Entity) {
        addPersistentCalls.add(AddPersistentCall(context: context))
    }

    func track<T: Analytics.Event>(event: T, _ contexts: [Entity]?) {
        trackCalls.add(TrackCall(event: event, contexts: contexts))
    }

    func resetPersistentContexts(_ contexts: [Entity]) {
        clearPersistentContextsCalls.add(contexts)
    }

    func childTracker(with contexts: [Entity]) -> Analytics.Tracker {
        NoopTracker()
    }
}

class MockSnowplow: Analytics.SnowplowTracker {
    struct TrackCall {
        let event: SelfDescribing
    }

    private(set) var trackCalls = Calls<TrackCall>()

    func track(event: SelfDescribing) {
        trackCalls.add(TrackCall(event: event))
    }
}

struct MockEvent: Analytics.Event, Equatable {
    static var schema = "mock-event"

    let value: Int
}

struct MockContext: Entity, Equatable {
    static var schema = "mock-context"

    let value: String
}

struct PersistentContext: Entity {
    static var schema = "persistent-context"

    let value: String
}
