// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import SwiftUI
import Textile
import WidgetKit

/// The main content view of an Item widget
struct ItemWidgetsView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment (\.hasVeryLargeFonts)
    private var hasVeryLargeFonts

    let items: [ItemRowContent]

    /// Actual items to display: reduce by 1 for accessibility categories
    private var actualItems: [ItemRowContent] {
        hasVeryLargeFonts ? items.dropLast() : items
    }

    private var expectedNumberOfItems: Int {
        switch widgetFamily {
        case .systemMedium:
            return hasVeryLargeFonts ? 1 : 2
        case .systemLarge:
            return hasVeryLargeFonts ? 3 : 4
        default:
            // Placeholder value. We'll add more values
            // as we support more widget families.
            return 0
        }
    }

    var body: some View {
        GeometryReader { content in
        VStack(alignment: .leading) {
            ItemWidgetsHeader(title: Localization.Widgets.RecentSaves.title)
            ForEach(actualItems) { entry in
                ItemWidgetsRow(
                    title: entry.content.title.isEmpty ? entry.content.url : entry.content.title,
                    domain: entry.content.bestDomain,
                    readingTime: entry.content.readingTime,
                    image: entry.image
                )
                .padding(.top, cellPadding(for: widgetFamily))
                .padding(.bottom, cellPadding(for: widgetFamily))
            }
            Spacer()
        }
        .maxThumbnailSize(maxThumbnailSize(for: content.size.height))
        }
    }

    /// Defines a maximum thumbnail width and height equal to the cell height, to prevent
    ///  the thumbnail from extending too much into the cell
    /// - Parameter totalHeight: the total height of the widget
    /// - Returns: the calculated maximum width
    private func maxThumbnailSize(for totalHeight: CGFloat) -> CGFloat {
        guard expectedNumberOfItems > 0 else {
            // fail safe: this should not happen, but in case, we won't crash
            // 80 is the default size of a thumbnail
            return 80
        }

        // approximate header height to subtract to the total height
        // does not need to be exact since the resulting width would only
        // vary slightly
        let verticalPadding: CGFloat = 18
        let numberOfItems = CGFloat(expectedNumberOfItems)
        let itemsSpacing: CGFloat = 2
        return (totalHeight - verticalPadding) / numberOfItems - itemsSpacing
    }

    private func cellPadding(for family: WidgetFamily) -> CGFloat {
        if case .systemMedium = family {
            return 2
        }
        return 4
    }
}
