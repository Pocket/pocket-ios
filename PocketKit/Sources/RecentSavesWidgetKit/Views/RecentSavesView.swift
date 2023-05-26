// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct RecentSavesView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    /// The list of saved items to be displayed
    let entry: RecentSavesProvider.Entry

    var body: some View {
        LabeledContent(entry.content.first!.title, value: entry.content.first!.url)
    }
}

struct RecentSavesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSavesView(entry: RecentSavesEntry(date: Date(), content: [.placeHolder]))
    }
}
