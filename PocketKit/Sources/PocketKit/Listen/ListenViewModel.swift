//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/24/23.
//

import Foundation
import Sync
import PKTListen

class ListenViewModel: PKTListenDataSource<PKTListDiffable> {
    static func source(savedItems: [SavedItem]?) -> ListenViewModel {
        let config = PKTListenAppKusariConfiguration()

        guard let languages = PKTListen.supportedLanguages else {
            return ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
                source.hasMore = false
                Log.debug("Loaded Listen with no items")
                complete(nil, ["index": NSNumber(value: 0)], [])
            })
        }

        let allItems: [PKTKusari<PKTListenItem>] = savedItems?.compactMap { $0 }.filter({savedItem in
            if savedItem.estimatedAlbumDuration <= 60 {
                return false
            }
// Below is the legacy listen logic, however we did not include wordCount in our intial data model so not all users will have it., So instead we just ensure our albumDuration is above 0
//            guard let wordCount = savedItem.item?.wordCount?.intValue, wordCount > PKTListen.minimumWordCount, wordCount < PKTListen.maximumWordCount else {
//                //Back up to using time to read, because MVP did not include wordCount
//                guard let timeToRead = savedItem.item?.timeToRead?.intValue, timeToRead > 0 else {
//                    return false
//                }
//
//                return true
//            }

            guard let language = savedItem.albumLanguage else {
                return false
            }

            if !languages.contains(language) {
                return false
            }

            return savedItem.item?.isArticle ?? false
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

        return ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(allItems.count) articles")
            complete(nil, ["index": NSNumber(value: allItems.count)], allItems)
        })
    }
}
