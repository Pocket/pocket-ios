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
    let deeplinkURL: URL?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .style(.header.sansSerif.w8)
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
        .widgetURL(deeplinkURL)
    }
}

/// Thumbnail view of an Item widget row
struct ItemThumbnail: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    @Environment(\.thumbnailWidth)
    private var maxThumbnailSize

    let image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: maxThumbnailSize, height: maxThumbnailSize / 1.4)
            .cornerRadius(16)
    }
}
