// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


extension Item {
    typealias RemoteItem = UserByTokenQuery.Data.UserByToken.SavedItem.Edge.Node
    
    func update(from remoteItem: RemoteItem) {
        domain = remoteItem.item.domainMetadata?.name ?? remoteItem.item.domain ?? "No Domain"
        title = remoteItem.item.title
        url = URL(string: remoteItem.url)

        if let imageURL = remoteItem.item.topImageUrl {
            thumbnailURL = URL(string: imageURL)
        }

        if let time = remoteItem.item.timeToRead {
            timeToRead = Int32(time)
        }

        guard let timeInterval = TimeInterval(remoteItem._createdAt) else {
            return
        }
        
        let interval = round(timeInterval / 1000)
        timestamp = Date(timeIntervalSince1970: interval)
    }
}
