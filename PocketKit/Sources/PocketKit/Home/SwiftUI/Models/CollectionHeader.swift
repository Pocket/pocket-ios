// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Model of a header for a collection of cards
/// **NOTE: this is currently used for native collections, but can be used for any collection of cards
struct CollectionHeader {
    let title: String
    let intro: String?
    let numberOfItems: Int
    let author: String
}
