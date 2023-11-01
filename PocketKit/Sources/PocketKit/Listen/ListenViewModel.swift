// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import PKTListen
import SharedPocketKit

class ListenViewModel: PKTListenDataSource<PKTListDiffable> {
    public var title: String = "Unknown"

    static func source(savedItems: [SavedItem]?, title: String) -> ListenViewModel {
        let config = PKTListenAppKusariConfiguration()

        let listenItems: [PKTKusari<PKTListenItem>] = savedItems?
            .compactMap { $0 }
            .filter { $0.isEligibleForListen }
            .compactMap { PKTListenKusariCreate($0.albumID!, PKTListenQueueSectionType.item.rawValue, $0, config) }
        ?? []

        DispatchQueue.global(qos: .background).async {
            // Warm up the first 6 images
            listenItems.prefix(6).forEach({ listenItem in
                listenItem.warmImage()
            })
        }

        let viewModel = ListenViewModel(context: ["index": NSNumber(value: 0)]) { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(listenItems.count) articles")
            complete(nil, ["index": NSNumber(value: listenItems.count)], listenItems)
        }
        viewModel.title = title
        return viewModel
    }
}
