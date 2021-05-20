// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


extension Item {
    typealias RemoteItem = UserByTokenQuery.Data.UserByToken.UserItem.Node.AsyncItem.Item
    
    func update(from remoteItem: RemoteItem) {
        domain = remoteItem.domainMetadata?.name ?? remoteItem.domain ?? "No Domain"
        title = remoteItem.title
        url = URL(string: remoteItem.givenUrl)
        
        if let imageURL = remoteItem.topImageUrl {
            thumbnailURL = URL(string: imageURL)
        }
        
        if let time = remoteItem.timeToRead {
            timeToRead = Int32(time)
        }
        
        if let unixTimestamp = remoteItem.userItem?._createdAt,
           let timeInterval = TimeInterval(unixTimestamp) {
            let interval = round(timeInterval / 1000)
            timestamp = Date(timeIntervalSince1970: interval)
        }
    }
}
