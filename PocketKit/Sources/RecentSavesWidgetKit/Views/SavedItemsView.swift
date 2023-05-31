// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import Textile

/// Recent Saves widget - recent saves list view
struct SavedItemsView: View {
    let items: [SavedItemRowContent]

    var body: some View {
        ForEach(items) { entry in
            SavedItemRow(title: entry.content.title.isEmpty ? entry.content.url : entry.content.title,
                         domain: entry.content.bestDomain,
                         readingTime: entry.content.readingTime,
                         image: entry.image)
            .padding(.bottom, 8)
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
}

/// Recent Saves widget - saved item view
struct SavedItemRow: View {
    let title: String
    let domain: String
    let readingTime: String?
    let image: Image?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(AttributedString(NSAttributedString(string: title, style: .title)))
                Spacer()
                if let image {
                    ItemThumbnail(image: image)
                }
            }
            .lineLimit(2)
            if let readingTime {
                Text(AttributedString(NSAttributedString(string: domain + " - " + readingTime, style: .domain)))
            } else {
                Text(AttributedString(NSAttributedString(string: domain, style: .domain)))
            }
        }
    }
}

/// Recent Saves widget - saved item thumbnail
struct ItemThumbnail: View {
    let image: Image

    var body: some View {
        image
            .resizable()
            .frame(width: RecentSavesProvider.defaultThumbnailSize.width,
                   height: RecentSavesProvider.defaultThumbnailSize.height)
            .cornerRadius(8)
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with(color: .ui.black1).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail) // .with(lineSpacing: 4)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey8).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey8).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
