// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import TipKit

// NOTE: we cannot use the same type for different tips because, when a tip is dismissed
// from the dismiss button, all tips of that type are invalidated..

/// Swipe highlights, Reader
@available(iOS 17.0, *)
struct SwipeHighlightsTip: Tip {
    let id = "pocketTips.reader.swipeHighlights"
    let title: Text = Text(Localization.Tips.SwipeHighlights.title)
    let message: Text? = Text(Localization.Tips.SwipeHighlights.message)
    let image: Image? =  Image(uiImage: UIImage(asset: .highlights))
    let options = [Tips.MaxDisplayCount(1)]
    var rules: [Rule] {
        #Rule(PocketTipEvents.showSwipeHighlightsTip) {
            $0.donations.count == 1
        }
    }
}

/// Swipe to archive, Saves
@available(iOS 17.0, *)
struct SwipeArchiveTip: Tip {
    let id = "pocketTips.saves.swipeArchive"
    let title = Text(Localization.Tips.SwipeToArchive.title)
    let message: Text? = Text(Localization.Tips.SwipeToArchive.message)
    let image: Image? = Image(uiImage: UIImage(asset: .archive))
    let options = [Tips.MaxDisplayCount(1)]
    var rules: [Rule] {
        #Rule(PocketTipEvents.showSwipeArchiveTip) {
            $0.donations.count == 1
        }
    }
}

/// New Recommendation Widget, Home
@available(iOS 17.0, *)
struct NewRecommendationsWidgetTip: Tip {
    let id = "pocketTips.home.newRecommendationsWidget"
    let title = Text(Localization.Tips.RecommendationsWidget.SelectTopic.title)
    let message: Text? = Text(Localization.Tips.RecommendationsWidget.SelectTopic.message)
    let image: Image? = nil
    let options = [Tips.MaxDisplayCount(1)]
    var rules: [Rule] {
        #Rule(PocketTipEvents.showNewRecommendationsWidgetTip) {
            $0.donations.count == 1
        }
    }
}

/// Shared With You, Home
@available(iOS 17.0, *)
struct SharedWithYouTip: Tip {
    let id = "pocketTips.home.sharedWithYouActions"
    let title = Text(Localization.Tips.SharedWithYouActions.title)
    let message: Text? = Text(Localization.Tips.SharedWithYouActions.message)
    let image: Image? = nil
    let options = [Tips.MaxDisplayCount(1)]
    var rules: [Rule] {
        #Rule(PocketTipEvents.showSharedWithYouTip) {
            $0.donations.count == 1
        }
    }
}

@available(iOS 17.0, *)
enum PocketTipEvents {
    static let showNewRecommendationsWidgetTip = Tips.Event(id: "pocketTips.events.showNewRecommendationsWidgetTip")
    static let showSwipeHighlightsTip = Tips.Event(id: "pocketTips.events.showSwipeHighlightsTip")
    static let showSwipeArchiveTip = Tips.Event(id: "pocketTips.events.showSwipeArchiveTip")
    static let showSharedWithYouTip = Tips.Event(id: "pocketTips.events.showSharedWithYouTip")
}
