// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync


struct ItemDestinationView: View {
    @ObservedObject
    var selection: ItemSelection

    @ObservedObject
    private var settings: ReaderSettings

    init(
        selection: ItemSelection,
        readerSettings: ReaderSettings
    ) {
        self.selection = selection
        self.settings = readerSettings
    }

    private var item: Item? {
        selection.selectedItem
    }

    private var article: Article? {
        item?.particle
    }

    var characterDirection: LayoutDirection {
        item?.characterDirection ?? LayoutDirection.leftToRight
    }

    var body: some View {
        if let article = article {
            ArticleView(article: article)
                .environmentObject(settings)
                .environment(\.characterDirection, characterDirection)
        } else {
            // TODO: Implement a view for when an article for the item doesn't exist.
            EmptyView()
        }
    }
}
