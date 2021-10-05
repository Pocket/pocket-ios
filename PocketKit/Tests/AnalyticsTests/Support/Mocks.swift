// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics
import SnowplowTracker


class MockTracker: Analytics.Tracker {
    struct TrackCall {
        let event: SnowplowEvent
        let contexts: [SnowplowContext]?
    }

    struct AddPersistentCall {
        let context: SnowplowContext
    }

    private(set) var trackCalls = Calls<TrackCall>()
    private(set) var addPersistentCalls = Calls<AddPersistentCall>()
    
    func addPersistentContext(_ context: SnowplowContext) {
        addPersistentCalls.add(AddPersistentCall(context: context))
    }
    
    func track<T: SnowplowEvent>(event: T, _ contexts: [SnowplowContext]?) {
        trackCalls.add(TrackCall(event: event, contexts: contexts))
    }
    
    func childTracker(with contexts: [SnowplowContext]) -> Analytics.Tracker {
        NoopTracker()
    }
}

class MockSnowplow: SnowplowTracking {
    struct TrackCall {
        let event: SelfDescribing
    }
    
    private(set) var trackCalls = Calls<TrackCall>()
    
    func track(event: SelfDescribing) {
        trackCalls.add(TrackCall(event: event))
    }
}

struct MockEvent: SnowplowEvent, Equatable {
    static var schema = "mock-event"
    
    let value: Int
}

struct MockContext: SnowplowContext, Equatable {
    static var schema = "mock-context"
    
    let value: String
}

struct PersistentContext: SnowplowContext {
    static var schema = "persistent-context"
    
    let value: String
}
