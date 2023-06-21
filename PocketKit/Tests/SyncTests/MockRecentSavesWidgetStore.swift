// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import SharedPocketKit

class MockRecentSavesWidgetStore: ItemWidgetsStore {
    var isLoggedIn: Bool = false

    func setLoggedIn(_ isLoggedIn: Bool) {}

    var recentSaves: [SharedPocketKit.ItemContent] = []

    func updateRecentSaves(_ items: [SharedPocketKit.ItemContent]) throws {}
}
