// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics


class MockTracker: Tracker {
    struct TrackCall {
        let event: SnowplowEvent
        let contexts: [SnowplowContext]?
    }
    
    private var persistentContexts: [SnowplowContext] = []
    
    private(set) var trackCalls = Calls<TrackCall>()
    
    func addPersistentContext(_ context: SnowplowContext) {
        
    }
    
    func track<T: SnowplowEvent>(event: T, _ contexts: [SnowplowContext]?) {
        trackCalls.add(TrackCall(event: event, contexts: contexts))
    }
    
    func childTracker(with contexts: [SnowplowContext]) -> Tracker {
        NoopTracker()
    }
}

struct MockEvent: SnowplowEvent {
    static var schema = "mock-event"
    
    let value: Int
}

struct MockContext: SnowplowContext {
    static var schema = "mock-context"
    
    let value: String
}
