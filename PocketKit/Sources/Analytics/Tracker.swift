// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SnowplowTracker


public protocol Tracker {
    func addPersistentContext(_ context: SnowplowContext)
    func track<T: SnowplowEvent>(event: T, _ contexts: [SnowplowContext]?)
}

public extension Tracker {
    func addPersistentContexts(_ contexts: [SnowplowContext]) {
        contexts.forEach { addPersistentContext($0) }
    }
}

public class PocketTracker: Tracker {
    private let snowplow: SnowplowTracking
    
    private var persistentContexts: [SnowplowContext] = []
    
    public init(snowplow: SnowplowTracking) {
        self.snowplow = snowplow
    }
    
    public func addPersistentContext(_ context: SnowplowContext) {
        persistentContexts.append(context)
    }
    
    public func track<T: SnowplowEvent>(event: T, _ contexts: [SnowplowContext]?) {
        guard let event = snowplowEvent(from: event) else {
            return
        }
        
        let contexts = contexts ?? []
        let merged = contexts + persistentContexts
        let snowplowContexts = snowplowContexts(from: merged)
        event.contexts.addObjects(from: snowplowContexts)
        
        snowplow.track(event: event)
    }
}

extension PocketTracker {
    private func snowplowEvent<T: SnowplowEvent>(from event: T) -> SelfDescribing? {
        guard let data = try? JSONEncoder().encode(event),
              let deserialized = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let eventJSON = SelfDescribingJson(schema: type(of: event).schema, andData: deserialized as NSObject) else {
                  return nil
              }
        return SelfDescribing(eventData: eventJSON)
    }
    
    private func snowplowContexts(from contexts: [SnowplowContext]) -> [SelfDescribingJson] {
        var uiHierarchy: UInt = 0
        // UIContexts are returned outside-in, such that the parent precedes the child.
        // However, in Snowplow, the hierarchy starts at the lowest-level of the contexts.
        // Since we don't know how deeply nested the view hierarchy will be up-front,
        // we have to reverse the contexts to go inside-out, such that the child precedes the parent,
        // and update the hierarchy appropriately.
        let contexts = contexts.reversed().map { (context) -> SnowplowContext in
            if let context = context as? UIContext {
                let context = context.with(hierarchy: uiHierarchy)
                uiHierarchy += 1
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

private extension UIContext {
    func with(hierarchy: UIHierarchy) -> UIContext {
        UIContext(
            type: type,
            hierarchy: hierarchy,
            identifier: identifier,
            componentDetail: componentDetail,
            index: index
        )
    }
}
