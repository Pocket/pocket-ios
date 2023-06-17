// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import WidgetKit

/// A single row of an Item widget
struct ItemWidgetsRow: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment (\.hasVeryLargeFonts)
    private var hasVeryLargeFonts

    let title: String
    let domain: String
    let readingTime: String?
    let image: Image?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .style(.header.sansSerif.w8)
                    .lineLimit(lineLimit(for: widgetFamily))
                    .fixedSize(horizontal: false, vertical: true)
                if let readingTime {
                    Text(domain + " - " + readingTime)
                        .style(.domain)
                } else {
                    Text(domain)
                        .style(.domain)
                }
            }
            Spacer()
            if let image {
                ItemThumbnail(image: image)
            }
        }
    }

    private func lineLimit(for family: WidgetFamily) -> Int {
        if case .systemMedium = family {
            return hasVeryLargeFonts ? 3 : 2
        }
        // We might need to handle other widget categories when supported
        return 3
    }
}

/// Thumbnail view of an Item widget row
struct ItemThumbnail: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment(\.maxThumbnailWidth)
    private var maxThumbnailWidth

    let image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                maxWidth: maxThumbnailWidth
            )
            .cornerRadius(8)
    }
}
