// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Analytics
import SnowplowTracker


class SnowplowTrackerTests: XCTestCase {
    func test_trackCreatesCorrectEventWithContexts() {
        let mock = MockSnowplow()
        let tracker = PocketTracker(snowplow: mock)
        
        let persistent = PersistentContext(value: "persistent")
        tracker.addPersistentContext(persistent)
        
        let contextA = MockContext(value: "A")
        let contextB = MockContext(value: "B")
        let event = MockEvent(value: 0)
        
        tracker.track(event: event, [contextA, contextB])
        
        XCTAssertEqual(mock.trackCalls.last?.event.schema, MockEvent.schema)
        XCTAssertEqual(mock.trackCalls.last?.event.payload, ["value": event.value as NSNumber])
        let eventContexts = mock.trackCalls.last?.event.contexts as! [SelfDescribingJson]
        
        let eventContextData = eventContexts.map { $0.data as! [String: String] }
        XCTAssertEqual(eventContextData, [
            ["value": persistent.value],
            ["value": contextB.value],
            ["value": contextA.value]
        ])
        let eventContextSchemas = eventContexts.map { $0.schema }
        XCTAssertEqual(eventContextSchemas, [
            "persistent-context",
            "mock-context",
            "mock-context"
        ])
    }
}
