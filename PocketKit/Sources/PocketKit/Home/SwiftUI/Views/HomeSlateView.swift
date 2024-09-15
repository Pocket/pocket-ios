// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import Sync
import SwiftData

struct HomeSlateView: View {
    let remoteID: String
    let slateTitle: String
    let recommendations: [Recommendation]

    var heroRecommendations: [Recommendation] {
        var recommendations = self.recommendations
        var actualRecommendations = [Recommendation]()
        (0..<3).forEach { _ in
            let element = recommendations.removeFirst()
            actualRecommendations.append(element)
        }
        return actualRecommendations
    }

    var carouselRecommendations: [Recommendation] {
        Array(recommendations.dropFirst(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text(slateTitle)
                HomeHeroSection(remoteID: remoteID, recommendations: heroRecommendations)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            HomeCarouselSection(remoteID: remoteID, recommendations: carouselRecommendations)
        }
    }
}
