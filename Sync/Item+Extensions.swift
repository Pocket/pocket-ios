// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


extension Item {
    typealias RemoteItem = UserByTokenQuery.Data.UserByToken.SavedItem.Edge.Node
    
    func update(from remoteItem: RemoteItem) {
        domain = remoteItem.item.domain
        title = remoteItem.item.title
        url = URL(string: remoteItem.url)
        particleJSON = remoteItem.item.particleJson

        if let context = managedObjectContext {
            domainMetadata = DomainMetadata(context: context)
            domainMetadata?.name = remoteItem.item.domainMetadata?.name
        }

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

    public var particle: Article? {
        return particleJSON?.data(using: .utf8).flatMap { data in
            let decoder = JSONDecoder()
            return try? decoder.decode(Article.self, from: data)
        }
    }
}
