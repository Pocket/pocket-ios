// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Kingfisher
import SharedPocketKit
import SwiftUI
import Textile
import WidgetKit

struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        ForEach(entry.content) { entry in
            SavedItemRow(title: entry.title.isEmpty ? entry.url : entry.title, imageUrl: entry.imageUrl)
                .padding()
                .cornerRadius(16)
        }
    }
}

struct SavedItemRow: View {
    let title: String
    let imageUrl: String?

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(3)
            Spacer()
            if let imageUrl, let url = URL(string: imageUrl) {
                ItemThumbnail(url: url)
            }
        }
    }
}

struct ItemThumbnail: View {
    let url: URL
    private static let imageSize = CGSize(width: 48, height: 36)

    private var bestURL: URL {
        let builder = CDNURLBuilder()
        return builder.imageCacheURL(for: url, size: Self.imageSize) ?? url
    }

    var body: some View {
        KFImage.url(bestURL)
            .onSuccess { _ in
                WidgetCenter.shared.reloadTimelines(ofKind: "RecentSavesWidget")
            }
            .resizable()
            .frame(width: Self.imageSize.width, height: Self.imageSize.height)
            .cornerRadius(8)
    }
}
