// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Analytics
import SnowplowTracker

class MockTracker: Analytics.Tracker {
    struct OldTrackCall {
        let event: Analytics.OldEvent
        let contexts: [Context]?
    }

    struct TrackCall {
        let event: Analytics.Event
    }

    struct AddPersistentCall {
        let entity: Entity
    }

    private(set) var oldTrackCalls = Calls<OldTrackCall>()
    private(set) var trackCalls = Calls<TrackCall>()
    private(set) var addPersistentCalls = Calls<AddPersistentCall>()
    private(set) var clearPersistentContextsCalls = Calls<[Entity]>()
    private(set) var clearPersistentFeatureContextsCalls = Calls<[FeatureFlagEntity]>()

    func addPersistentEntity(_ entity: Analytics.Entity) {
        addPersistentCalls.add(AddPersistentCall(entity: entity))
    }

    func track<T: Analytics.OldEvent>(event: T, _ contexts: [Context]?) {
        oldTrackCalls.add(OldTrackCall(event: event, contexts: contexts))
    }

    func track(event: Analytics.Event) {
        trackCalls.add(TrackCall(event: event))
    }

    func resetPersistentEntities(_ entities: [Analytics.Entity]) {
        clearPersistentContextsCalls.add(entities)
    }

    func resetPersistentFeatureEntities(_ entities: [Analytics.FeatureFlagEntity]) {
        clearPersistentFeatureContextsCalls.add(entities)
    }

    func childTracker(with contexts: [Context]) -> Analytics.Tracker {
        NoopTracker()
    }
}

class MockSnowplow: Analytics.SnowplowTracker {
    struct TrackCall {
        let event: SelfDescribing
    }

    struct AddPersistentCall {
        let entity: Entity
    }

    private(set) var trackCalls = Calls<TrackCall>()
    private(set) var clearPersistentContextsCalls = Calls<[Entity]>()
    private(set) var clearPersistentFeatureContextsCalls = Calls<[FeatureFlagEntity]>()
    private(set) var addPersistentCalls = Calls<AddPersistentCall>()

    func track(event: SelfDescribing) {
        trackCalls.add(TrackCall(event: event))
    }

    func addPersistentEntity(_ entity: Entity) {
        addPersistentCalls.add(AddPersistentCall(entity: entity))
    }

    func resetPersistentEntities(_ entities: [Entity]) {
        clearPersistentContextsCalls.add(entities)
    }

    func resetPersistentFeatureEntities(_ entities: [FeatureFlagEntity]) {
        clearPersistentFeatureContextsCalls.add(entities)
    }
}

struct MockEvent: Analytics.OldEvent, Equatable {
    static var schema = "mock-event"

    let value: Int
}

struct MockEntity: Entity, Context, Equatable {
    static var schema = "mock-context"

    let value: String

    func toSelfDescribingJson() -> SelfDescribingJson {
        SelfDescribingJson(schema: MockEntity.schema, andDictionary: ["value": value])
    }
}

struct PersistentContext: Entity {
    static var schema = "persistent-context"

    let value: String

    func toSelfDescribingJson() -> SelfDescribingJson {
        SelfDescribingJson(schema: PersistentContext.schema, andDictionary: ["value": value])
    }
}
