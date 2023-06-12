// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import WidgetKit

struct RecentSavesEntry: TimelineEntry {
    let date: Date
    let contentType: RecentSavesContentType
}

/// Determines which type of content to display in the Recent Saves widget.
enum RecentSavesContentType {
    case empty
    case loggedOut
    case error
    case items([SavedItemRowContent])
}
