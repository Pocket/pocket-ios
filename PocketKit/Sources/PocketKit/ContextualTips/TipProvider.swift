// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import TipKit

@available(iOS 17.0, *)
class TipProvider {
    static var highlightTip: PocketTip {
        PocketTip(
            title: Text("Swipe to highlight or delete highlights"),
            message: Text("Swipe left to highlight an entire paragraph, or delete highlights in a paragraph."),
            image: Image(uiImage: UIImage(asset: .highlights))
        )
    }

    static var archiveTip: PocketTip {
        PocketTip(
            title: Text("Swipe to archive"),
            message: Text("Swipe left to quickly archive an article."),
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
    // var options: [TipOption] = [Tips.MaxDisplayCount(100)]
    // TODO: we can add parameters and rules if needed
}
