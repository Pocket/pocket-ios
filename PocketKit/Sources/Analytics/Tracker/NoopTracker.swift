// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct NoopTracker: Tracker {
    public init() { }
    
    public func addPersistentContext(_ context: Context) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }
    
    public func track<T: Event>(event: T, _ contexts: [Context]?) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }
    
    public func childTracker(with contexts: [Context]) -> Tracker {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }

    public func resetPersistentContexts(_ contexts: [Context]) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }
}
