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
    var id = UUID()
    let title: Text = Text(Localization.Tips.SwipeHighlights.title)
    let message: Text? = Text(Localization.Tips.SwipeHighlights.message)
    let image: Image? =  Image(uiImage: UIImage(asset: .highlights))
    let options = [Tips.MaxDisplayCount(3)]
}

/// Swipe to archive, Saves
@available(iOS 17.0, *)
struct SwipeArchiveTip: Tip {
    var id = UUID()
    let title = Text(Localization.Tips.SwipeToArchive.title)
    let message: Text? = Text(Localization.Tips.SwipeToArchive.message)
    let image: Image? = Image(uiImage: UIImage(asset: .archive))
    let options = [Tips.MaxDisplayCount(3)]
}
