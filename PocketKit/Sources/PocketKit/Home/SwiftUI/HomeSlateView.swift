// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import SwiftData

struct HomeSlateView: View {
    let remoteID: String
    let slateTitle: String
    @Query var recommendations: [Recommendation]

    init(remoteID: String, slateTitle: String) {
        self.remoteID = remoteID
        self.slateTitle = slateTitle
        let predicate = #Predicate<Recommendation> {
            $0.slate?.remoteID == remoteID
        }
        _recommendations = Query(filter: predicate, sort: \Recommendation.sortIndex, order: .forward)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TODO: replace with section header
            Text(slateTitle)
            if let item = recommendations.first?.item {
                HomeHeroView(model: HomeItemCellViewModel2(item: item, imageURL: item.topImageURL))
            }
//            List(recommendations) { recommendation in
//                if let item = recommendation.item {
//                    HomeHeroView(model: HomeItemCellViewModel2(item: item, imageURL: item.topImageURL))
//                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
//                }
//            }
//            .listStyle(.plain)
        }
        .padding()
    }
}

private extension HomeSlateView {
    static func makePreview() -> some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try? ModelContainer(for: Item.self, Slate.self, Recommendation.self, configurations: config)
        let slate = Slate(experimentID: "", remoteID: "previewSlateRemoteID", requestID: "")

        for i in 1..<3 {
            let recommendation = Recommendation(analyticsID: "", remoteID: "\(i)")
            recommendation.slate = slate
            let item = Item(givenURL: "https://getpocket.com", remoteID: "item_\(i)")
            item.topImageURL = URL(string: "https://www.mozilla.org/media/img/home/2018/newsletter-graphic.3debb24fbacc.png")!
            item.title = "Preview Title \(i)"
            item.domain = "Pocket"
            recommendation.item = item
            container!.mainContext.insert(recommendation)
        }

        return HomeSlateView(remoteID: "previewSlateRemoteID", slateTitle: "")
            .modelContainer(container!)
    }
}

#Preview {
    HomeSlateView.makePreview()
}
