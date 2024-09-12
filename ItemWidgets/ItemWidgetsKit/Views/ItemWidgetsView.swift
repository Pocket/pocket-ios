// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import WidgetKit

/// The main content view of an Item widget
struct ItemWidgetsView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment(\.hasVeryLargeFonts)
    private var hasVeryLargeFonts

    @Environment(\.maxNumberOfItems)
    private var maxNumberOfItems

    let items: [ItemRowContent]
    let title: String

    /// Adjust items to display based on the accessibility category and handle a partially populated list.
    /// Logic details:
    /// - `.systemMedium`: just display the available items; if it's just one, take up the entire widget,
    ///         Accessibility categories will have the list reduced by 1.
    ///  - `.systemLarge`: if there's only one item, push it up by inserting empty rows, otherwise,
    ///    take up the entire space for the available items. Accessibility categories will have the list reduced by 1.
    private var itemsToDisplay: [ItemRowContent] {
        // large accessibility categories - reduce the list by 1
        let itemsDelta = items.count - maxNumberOfItems
        if itemsDelta > 0 {
            return Array(items.prefix(maxNumberOfItems))
            // .systemLarge with 1 item only (accessibility or regular) - insert two empty items
        } else if (itemsDelta == -2 && hasVeryLargeFonts) || itemsDelta == -3 {
            var itemsToReturn = items
            itemsToReturn.append(ItemRowContent.empty)
            itemsToReturn.append(ItemRowContent.empty)
            return itemsToReturn
        }
        return items
    }

    var body: some View {
        VStack(alignment: .leading) {
            ItemWidgetsHeader(title: title)
            ItemWidgetsListView(items: itemsToDisplay)
        }
    }
}
