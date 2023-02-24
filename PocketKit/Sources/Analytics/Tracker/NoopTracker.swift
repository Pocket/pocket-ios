// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct NoopTracker: Tracker {
    public init() { }

    public func addPersistentEntity(_ entity: Entity) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }

    public func track<T: OldEvent>(event: T, _ contexts: [Context]?) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }

    public func track(event: Event, filename: String, line: Int, column: Int, funcName: String) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }

    public func childTracker(with contexts: [Context]) -> Tracker {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }

    public func resetPersistentEntities(_ entities: [Entity]) {
        fatalError("\(Self.self) cannot be used. Please set your environment's tracker to a valid tracker.")
    }
}
