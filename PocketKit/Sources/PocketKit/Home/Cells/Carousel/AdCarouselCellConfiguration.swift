// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Textile
import Localization

struct AdCarouselCellConfiguration: HomeCarouselCellConfiguration {
    private let ads: [PocketAd]

    private var currentIndex = 0

    private var currentAd: PocketAd {
        ads[currentIndex]
    }

    init(sequence: PocketAdsSequence) {
        self.ads = sequence.ads
    }
    var thumbnailURL: URL? {
        URL(string: currentAd.imageUrl)
    }

    var saveButtonMode: ItemCellSaveButton.Mode? {
        nil
    }

    var favoriteAction: ItemAction? {
        nil
    }

    var overflowActions: [ItemAction]? {
        // TODO: ADS - tbd overflow actions for ads
        nil
    }

    var saveAction: ItemAction? {
        nil
    }

    var attributedCollection: NSAttributedString? {
        nil
    }

    var attributedTitle: NSAttributedString {
        let content = NSMutableAttributedString()
        content.append(NSAttributedString(string: currentAd.title, style: .recommendation.title))
        content.append(NSAttributedString(string: "\n" + currentAd.description, style: .recommendation.title))
        return content
    }

    var attributedDomain: NSAttributedString {
        NSMutableAttributedString(string: "Sponsored", style: .recommendation.domain)
    }

    var attributedTimeToRead: NSAttributedString {
        return NSAttributedString(string: "", style: .recommendation.timeToRead)
    }

    var sharedWithYouUrlString: String? {
        nil
    }
}
