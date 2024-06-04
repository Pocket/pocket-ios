// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

final class LinkedTracker: Tracker {
    private let parent: Tracker
    private let contexts: [Context]

    init(parent: Tracker, contexts: [Context]) {
        self.parent = parent
        self.contexts = contexts
    }

    func addPersistentEntity(_ entity: Entity) {
        parent.addPersistentEntity(entity)
    }

    func track<T>(event: T, _ contexts: [Context]?) where T: OldEvent {
        let additional = contexts ?? []
        parent.track(event: event, self.contexts + additional)
    }

    func track(event: Event, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        parent.track(event: event, filename: filename, line: line, column: column, funcName: funcName)
    }

    @available(*, deprecated, message: "No longer need to use a child trackers")
    func childTracker(with contexts: [Context]) -> Tracker {
        LinkedTracker(parent: self, contexts: contexts)
    }

    func resetPersistentEntities(_ entities: [Entity]) {
        parent.resetPersistentEntities(entities)
    }
}
