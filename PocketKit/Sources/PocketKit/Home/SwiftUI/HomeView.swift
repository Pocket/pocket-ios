// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HomeView: View {
    @Query(sort: \Recommendation.sortIndex)
    var recommendations: [Recommendation]
    var body: some View {
        List(recommendations) { recommendation in
            if let item = recommendation.item {
                HomeHeroView(model: HomeItemCellViewModel2(item: item, imageURL: item.topImageURL))
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            }
        }
        .listStyle(.plain)
    }
}
