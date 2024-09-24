// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import Sync
import SwiftData

struct SlateView: View {
    let remoteID: String
    let slateTitle: String?
    let cards: [HomeCard]

    @Environment(\.useWideLayout)
    private var useWideLayout

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                if let slateTitle {
                    Text(AttributedString(NSAttributedString(string: slateTitle, style: .homeHeader.sectionHeader)))
                }
                HeroView(remoteID: remoteID, cards: herolCards)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            CarouselView(cards: carouselCards, useGrid: useWideLayout)
        }
    }
}

private extension SlateView {
    /// Determines how many hero cell should be used, depending on the user interface idiom and horizontal size class
    /// - Parameter isWideLayout: true if wide layout should be used
    /// - Returns: the actual number of hero cells
    static func heroCount(_ useWideLayout: Bool) -> Int {
        useWideLayout ? 2 : 1
    }

    /// Determines how many hero cells should be used
    var heroCount: Int {
        Self.heroCount(useWideLayout)
    }

    /// Extract the Hero recommendations
    var herolCards: [HomeCard] {
        Array(cards.prefix(upTo: heroCount))
    }

    /// Extract the carousel recommendations
    var carouselCards: [HomeCard] {
        Array(cards.dropFirst(heroCount))
    }
}
