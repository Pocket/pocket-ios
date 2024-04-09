// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import TipKit

@available(iOS 17.0, *)
class TipProvider {
    static var highlightTip: PocketTip {
        PocketTip(
            title: Text(Localization.Tips.SwipeHighlights.title),
            message: Text(Localization.Tips.SwipeHighlights.message),
            image: Image(uiImage: UIImage(asset: .highlights))
        )
    }

    static var archiveTip: PocketTip {
        PocketTip(
            title: Text(Localization.Tips.SwipeToArchive.title),
            message: Text(Localization.Tips.SwipeToArchive.message),
            image: Image(uiImage: UIImage(asset: .archive))
        )
    }
}

@available(iOS 17.0, *)
struct PocketTip: Tip {
    var id = UUID()
    let title: Text
    let message: Text?
    let image: Image?
    let options: [TipOption] = [Tips.MaxDisplayCount(3)]
    // TODO: we can add parameters and rules if needed
}
