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

        let allItems: [PKTKusari<PKTListenItem>] = savedItems?.compactMap { $0 }.compactMap({item in
            let v = PKTListenKusariCreate(item.albumID!, PKTListenQueueSectionType.item.rawValue, item, config)
            return v
        }) ?? []

        return ListenViewModel(context: ["index": NSNumber(value: 0)], loader: { source, context, complete in
           // let index = (context!["index"] as! NSNumber).intValue
           // let length = min(max(allItems.count-index, 0), 100)
           // var kusari = allItems[index...length]
//            var newKusari = kusari.map { k in
//                return k.merge(context?.merge(["index": NSNumber(value: index+length)], uniquingKeysWith: { (_, new) in new }))
//            }
            source.hasMore = false
            Log.debug("Loaded Listen with \(allItems.count)")
            complete(nil, ["index": NSNumber(value: allItems.count)], allItems)
        })
    }
}


