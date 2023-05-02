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

        guard let languages = PKTListen.supportedLanguages else {
            let viewModel = ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
                source.hasMore = false
                Log.debug("Loaded Listen with no items")
                complete(nil, ["index": NSNumber(value: 0)], [])
            })
            viewModel.title = title
            return viewModel
        }

        let allItems: [PKTKusari<PKTListenItem>] = savedItems?.compactMap { $0 }.filter({savedItem in
            if savedItem.remoteID == nil {
                return false
            }

            if savedItem.estimatedAlbumDuration <= 60 {
                return false
            }

            guard let language = savedItem.albumLanguage else {
                return false
            }

            if !languages.contains(language) {
                return false
            }

            return savedItem.item.isArticle
        }).compactMap({item in
            let v = PKTListenKusariCreate(item.albumID!, PKTListenQueueSectionType.item.rawValue, item, config)
            return v
        }) ?? []

        DispatchQueue.global(qos: .background).async {
            // Warm up the first 6 images
            allItems.prefix(6).forEach({ listenItem in
                listenItem.warmImage()
            })
        }

        let viewModel = ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(allItems.count) articles")
            complete(nil, ["index": NSNumber(value: allItems.count)], allItems)
        })
        viewModel.title = title
        return viewModel
    }
}
