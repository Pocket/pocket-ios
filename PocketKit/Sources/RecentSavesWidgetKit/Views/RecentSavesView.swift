// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        ForEach(entry.content) { entry in
            SavedItemRow(title: entry.title)
                .padding()
        }
    }
}

struct SavedItemRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .lineLimit(2)
            Spacer()
            Text("image goes here")
        }
    }
}

struct RecentSavesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSavesView(entry: RecentSavesEntry(date: Date(), content: [.placeHolder]))
    }
}
