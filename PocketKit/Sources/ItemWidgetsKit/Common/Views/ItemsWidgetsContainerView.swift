// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import SwiftUI
import Textile

/// Main view of an Item widget
struct ItemsWidgetsContainerView: View {
    @Environment (\.dynamicTypeSize)
    private var textSize

    /// The list of saved items to be displayed
    let entry: ItemsListEntry

    var body: some View {
        if case let .items(items) = entry.contentType {
            ItemWidgetsView(items: items)
                .hasVeryLargeFonts(textSize > .xLarge)
        } else {
            ItemWidgetsEmptyContentView(contentType: entry.contentType)
        }
    }
}
