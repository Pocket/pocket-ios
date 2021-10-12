// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import SnowplowTracker


struct UIContextsKey: EnvironmentKey {
    static var defaultValue: [UIContext] = []
}

struct TrackerKey: EnvironmentKey {
    static var defaultValue: Tracker = NoopTracker()
}

public extension EnvironmentValues {
    var uiContexts: [UIContext] {
        get { self[UIContextsKey.self] }
        set { self[UIContextsKey.self] = newValue }
    }
    
    var tracker: Tracker {
        get { self[TrackerKey.self] }
        set { self[TrackerKey.self] = newValue }
    }
}
