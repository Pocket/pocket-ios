// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

/// Recent Saves widget - recent saves list view
struct SavedItemsView: View {
    let items: [SavedItemRowContent]

    var body: some View {
        ForEach(items) { entry in
            SavedItemRow(title: entry.content.title.isEmpty ?
                         entry.content.url :
                            entry.content.title,
                         image: entry.image)
            .padding()
            .cornerRadius(16)
        }
    }
}

/// Recent Saves widget - saved item view
struct SavedItemRow: View {
    let title: String
    let image: Image?

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(3)
            Spacer()
            if let image {
                ItemThumbnail(image: image)
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
