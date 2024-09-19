// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct RecommendationsView: View {
    @Query(sort: \Slate.sortIndex, order: .forward)
    private var slates: [Slate]

    var body: some View {
        VStack(spacing: 32) {
            if !slates.isEmpty {
                ForEach(slates) { slate in
                    SlateView(
                        remoteID: slate.remoteID,
                        slateTitle: slate.name,
                        recommendations: slate.homeRecommendations
                    )
                }
            } else {
                // TODO: SWIFTUI - Replace with the lottie animation
                Text("Pocket")
            }
        }
    }
}

private extension Slate {
    var homeRecommendations: [Recommendation] {
        if let slice = recommendations?
            .sorted(by: { $0.sortIndex < $1.sortIndex })
            .prefix(upTo: 6) {
                return Array(slice)
            }
        return []
    }
}
