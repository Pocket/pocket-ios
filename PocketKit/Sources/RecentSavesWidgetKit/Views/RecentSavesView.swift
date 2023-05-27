// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Kingfisher
import SwiftUI
import Textile

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
        .background(Color(.ui.homeCellBackground))
    }
}

struct SavedItemRow: View {
    let title: String
    let imageUrl: String?

    var body: some View {
        GeometryReader { frame in
            HStack {
                Text(title)
                    .lineLimit(3)
                if let imageUrl, let url = URL(string: imageUrl) {
                    Spacer()
                    KFImage.url(url)
                        .resizable()
                        .frame(width: frame.size.width * 0.2)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct RecentSavesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSavesView(entry: RecentSavesEntry(date: Date(), content: [.placeHolder]))
    }
}
