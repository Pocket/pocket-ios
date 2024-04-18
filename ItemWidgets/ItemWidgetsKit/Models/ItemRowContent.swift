// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI

/// Wrapper type for an ItemContent instance with its thumbnail image (if any)
struct ItemRowContent: Identifiable, Equatable {
    let id = UUID()
    let content: ItemContent
    var image: Image?

    public static var empty: ItemRowContent {
        ItemRowContent(content: .empty)
    }
}
