// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import WidgetKit

struct ItemWidgetsListView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment (\.hasVeryLargeFonts)
    private var hasVeryLargeFonts

    let items: [ItemRowContent]

    private func cellSpacing(for family: WidgetFamily) -> CGFloat {
        if case .systemMedium = family {
            return 8
        }
        return 16
    }

    var body: some View {
        GeometryReader { content in
            VStack(spacing: cellSpacing(for: widgetFamily)) {
                ForEach(items) { entry in
                    if entry == .empty {
                        Spacer()
                            .frame(minHeight: 0, maxHeight: .infinity)
                    } else {
                        ItemWidgetsRow(
                            title: entry.content.title.isEmpty ? entry.content.url : entry.content.title,
                            domain: entry.content.bestDomain,
                            readingTime: entry.content.readingTime,
                            image: entry.image,
                            deeplinkURL: entry.content.pocketDeeplinkURL
                        )
                        .frame(minHeight: 0, maxHeight: .infinity)
                    }
                }
            }
            .thumbnailWidth(thumbnailWidth(for: content.size.height))
        }
    }

    /// Calculates the thumbnail width, based on an aspect ratio of 4/3 so the images can be scaled and remain aligned.
    /// The aspect ratio is different from the one in the app to prevent thumbnails from taking too much horizontal space.
    /// - Parameter totalHeight: the total height of the list view
    /// - Returns: the calculated width
    private func thumbnailWidth(for totalHeight: CGFloat) -> CGFloat {
        let aspectRatio: CGFloat = 1.4
        let numberOfItems = CGFloat(items.count)
        let rowHeight = (totalHeight - (cellSpacing(for: widgetFamily) * (numberOfItems - 1))) / numberOfItems
        return rowHeight * aspectRatio
    }
}
