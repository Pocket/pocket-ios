// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import class SnowplowTracker.SelfDescribing

public protocol SnowplowTracker: Sendable {
    func track(event: SelfDescribing)
    func addPersistentEntity(_ entity: Entity)
    func resetPersistentEntities(_ entities: [Entity])
}
