// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync
import Textile
import SharedWithYou

struct SharedWithYouView: View {
    @Query(sort: \SharedWithYouItem.sortOrder, order: .forward, animation: .easeIn)
    private var sharedWithYouItems: [SharedWithYouItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(SWHighlightCenter.highlightCollectionTitle)
                .style(.homeHeader.sectionHeader)
                .padding(.leading, 16)
            CarouselView(cards: cards, useGrid: false)
        }
    }
}

private extension SharedWithYouView {
    var cards: [HomeCard] {
        sharedWithYouItems.compactMap {
            if let item = $0.item {
                return HomeCard(
                    givenURL: item.givenURL,
                    imageURL: item.topImageURL,
                    sharedWithYouUrlString: $0.url,
                    uselargeTitle: false
                )
            }
            return nil
        }
    }
}
