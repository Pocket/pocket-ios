// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker
import Sync
import Foundation
import SharedPocketKit

public final class PocketTracker: Tracker {
    private let snowplow: SnowplowTracker

    public init(snowplow: SnowplowTracker) {
        self.snowplow = snowplow
    }

    public func track<T: OldEvent>(event: T, _ contexts: [Context]?) {
        guard let event = Event(from: event) else {
            return
        }

        let contexts = contexts ?? []
        let Contexts = Contexts(from: contexts)
        event.entities.append(contentsOf: Contexts)

        snowplow.track(event: event)
    }

    public func track(event: Event, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        Log.debug("Tracking \(String(describing: event))", filename: filename, line: line, column: column, funcName: funcName)
        let selfDescribing = event.toSelfDescribing()
        snowplow.track(event: selfDescribing)
    }

    public func childTracker(with contexts: [Context]) -> Tracker {
        return LinkedTracker(parent: self, contexts: contexts)
    }

    public func addPersistentEntity(_ entity: Entity) {
        snowplow.addPersistentEntity(entity)
    }

    public func resetPersistentEntities(_ entities: [Entity]) {
        snowplow.resetPersistentEntities(entities)
    }
}

extension PocketTracker {
    private func Event<T: OldEvent>(from event: T) -> SelfDescribing? {
        guard let data = try? JSONEncoder().encode(event),
              let deserialized = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
              else {
                  return nil
              }
        return SelfDescribing(eventData: SelfDescribingJson(schema: type(of: event).schema, andData: deserialized))
    }

    private func Contexts(from contexts: [Context]) -> [SelfDescribingJson] {
        var Hierarchy: UInt = 0
        // UIs are returned outside-in, such that the parent precedes the child.
        // However, in Snowplow, the hierarchy starts at the lowest-level of the contexts.
        // Since we don't know how deeply nested the view hierarchy will be up-front,
        // we have to reverse the contexts to go inside-out, such that the child precedes the parent,
        // and update the hierarchy appropriately.
        let contexts = contexts.reversed().map { (context) -> Context in
            if let context = context as? UIContext {
                let context = context.with(hierarchy: Hierarchy)
                Hierarchy += 1
                return context
            }

            return context
        }

        return contexts.compactMap { context -> SelfDescribingJson? in
            guard let data = context.jsonEncoded,
                  let deserialized = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                  else {
                      return nil
                  }
            return SelfDescribingJson(schema: type(of: context).schema, andData: deserialized)
        }
    }
}
