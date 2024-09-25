// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct RecentSavesView: View {
    @Query private var savedItems: [SavedItem]
    @EnvironmentObject private var mainViewModel: MainViewModel

    init() {
        let predicate = #Predicate<SavedItem> { $0.isArchived == false && $0.deletedAt == nil }
        let sortDescriptor = SortDescriptor<SavedItem>(\.createdAt, order: .reverse)
        var fetchDescriptor = FetchDescriptor<SavedItem>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 5
        _savedItems = Query(fetchDescriptor, animation: .easeIn)
    }

    var body: some View {
        if !carouselCards.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                makeHeader()
                CarouselView(cards: carouselCards, useGrid: false)
            }
        }
    }
}

private extension RecentSavesView {
    func makeHeader() -> some View {
        HStack {
            Text(Localization.recentSaves)
                .style(.homeHeader.sectionHeader)
            Spacer()
            Button(action: {
                mainViewModel.selectedSection = .saves
            }) {
                HStack {
                    Text(Localization.seeAll)
                        .style(.homeHeader.buttonText)
                    Image(asset: .chevronRight)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(.ui.teal2))
                        .frame(width: 6.75, height: 12)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
    var carouselCards: [HomeCard] {
        savedItems.compactMap {
            if let item = $0.item {
                return HomeCard(
                    givenURL: item.givenURL,
                    imageURL: item.topImageURL,
                    sharedWithYouUrlString: nil,
                    uselargeTitle: false
                )
            }
            return nil
        }
    }
}
