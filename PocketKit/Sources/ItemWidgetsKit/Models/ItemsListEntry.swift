// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit

struct ItemsListEntry: TimelineEntry {
    let date: Date
    let name: String
    let contentType: ItemsListContentType
}

/// Determines which type of content to display in the Recent Saves widget.
enum ItemsListContentType {
    case recentSavesEmpty
    case recommendationsEmpty
    case loggedOut
    case error
    case items([ItemRowContent])
}
