// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftData
import SwiftUI
import Sync

struct RecommendationsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Slate.sortIndex, order: .forward)
    private var slates: [Slate]

    var body: some View {
        VStack(spacing: 32) {
            if !slates.isEmpty {
                ForEach(slates) { slate in
                    HomeSlateView(
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
        // TODO: SWIFTUI - this is an alternative to the @Query, more efficient since we control when to fetch
        // but might miss updates from elsewhere on Slates (e.g. a remote fetch updates them). TBD if we want
        // to fetch explicitly, but then we need to update manually.
//        .onAppear {
//            let descriptor = FetchDescriptor<Slate>(sortBy: [SortDescriptor(\Slate.sortIndex, order: .forward)])
//            do {
//                slates = try modelContext.fetch(descriptor)
//            } catch {
//                print(error)
//            }
//        }
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
