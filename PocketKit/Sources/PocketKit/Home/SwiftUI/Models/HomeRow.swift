// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Model for a row of cards in a grid
struct HomeRow: Identifiable {
    var id = UUID()
    let cards: [HomeCard]
}
