// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker


public class PocketTracker: Tracker {
    private let snowplow: SnowplowTracker
    
    private var persistentContexts: [Context] = []
    
    public init(snowplow: SnowplowTracker) {
        self.snowplow = snowplow
    }
    
    public func addPersistentContext(_ context: Context) {
        persistentContexts.append(context)
    }
    
    public func track<T: Event>(event: T, _ contexts: [Context]?) {
        guard let event = Event(from: event) else {
            return
        }
        
        let contexts = contexts ?? []
        let merged = contexts + persistentContexts
        let Contexts = Contexts(from: merged)
        event.contexts.addObjects(from: Contexts)
        
        snowplow.track(event: event)
    }
    
    public func childTracker(with contexts: [Context]) -> Tracker {
        return LinkedTracker(parent: self, contexts: contexts)
    }

    public func resetPersistentContexts(_ contexts: [Context]) {
        persistentContexts = contexts
    }
}

extension PocketTracker {
    private func Event<T: Event>(from event: T) -> SelfDescribing? {
        guard let data = try? JSONEncoder().encode(event),
              let deserialized = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let eventJSON = SelfDescribingJson(schema: type(of: event).schema, andData: deserialized as NSObject) else {
                  return nil
              }
        return SelfDescribing(eventData: eventJSON)
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
                  let deserialized = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let context = SelfDescribingJson(schema: type(of: context).schema, andData: deserialized as NSObject) else {
                      return nil
                  }
            return context
        }
    }
}
