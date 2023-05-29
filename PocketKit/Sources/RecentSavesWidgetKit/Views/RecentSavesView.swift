// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI
import Textile

struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        ForEach(entry.content) { entry in
            SavedItemRow(title: entry.content.title.isEmpty ?
                         entry.content.url :
                            entry.content.title,
                         image: entry.image)
                .padding()
                .cornerRadius(16)
        }
    }
}

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
