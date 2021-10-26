// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Analytics


class LinkedTrackerTests: XCTestCase {
    func test_track_withPersistentContexts_forwardsPersistentContextsToParent() {
        let mockTracker = MockTracker()
        let context = MockContext(value: "persistent")
        
        let tracker = LinkedTracker(parent: mockTracker, contexts: [context])
        tracker.addPersistentContext(context)
       
        XCTAssertEqual(mockTracker.addPersistentCalls.last?.context as? MockContext, context)
    }
    
    func test_track_forwardsEventToParent() {
        let mockTracker = MockTracker()
        let event = MockEvent(value: 1337)
        
        let tracker = LinkedTracker(parent: mockTracker, contexts: [])
        tracker.track(event: event, nil)
       
        XCTAssertEqual(mockTracker.trackCalls.last?.event as? MockEvent, event)
    }
    
    func test_track_multipleChildren_forwardAllContexts() {
        let mockTracker = MockTracker()
        
        let contextA = MockContext(value: "context-a")
        let childA = LinkedTracker(parent: mockTracker, contexts: [contextA])
        
        let contextB = MockContext(value: "context-b")
        let childB = LinkedTracker(parent: childA, contexts: [contextB])
        
        let mockEvent = MockEvent(value: 1337)
        let mockContext = MockContext(value: "mock-context")
        childB.track(event: mockEvent, [mockContext])
        
        XCTAssertEqual(mockTracker.trackCalls.last?.contexts as? [MockContext], [contextA, contextB, mockContext])
    }
}
