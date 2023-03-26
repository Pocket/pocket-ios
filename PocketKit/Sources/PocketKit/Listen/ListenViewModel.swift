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

        let allItems: [PKTKusari<PKTListenItem>] = savedItems?.compactMap { $0 }.filter({savedItem in
            guard let wordCount = savedItem.item?.wordCount?.intValue, wordCount > PKTListen.minimumWordCount, wordCount < PKTListen.maximumWordCount else {
                return false
            }
            
            guard let language = savedItem.albumLanguage, ((PKTListen.supportedLanguages?.contains(language)) != nil) else {
                return false
            }
            
            return savedItem.item?.isArticle ?? false
        }).compactMap({item in
            let v = PKTListenKusariCreate(item.albumID!, PKTListenQueueSectionType.item.rawValue, item, config)
            return v
        }) ?? []

        return ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(allItems.count)")
            complete(nil, ["index": NSNumber(value: allItems.count)], allItems)
        })
    }
}
