// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct HomeButtonAction: Identifiable, Hashable {
    static func == (lhs: HomeButtonAction, rhs: HomeButtonAction) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
    }

    var id: UUID
    let action: () -> Void
    let title: String?

    init(title: String? = nil, action: @escaping () -> Void) {
        self.id = UUID()
        self.action = action
        self.title = title
    }
}
