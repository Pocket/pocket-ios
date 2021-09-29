// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension UserByTokenQuery.Data.UserByToken.SavedItem.Edge.Node {
    var preferredURLString: String {
        item.fragments.itemParts?.preferredURLString
        ?? item.fragments.pendingItemParts?.url
        ?? url
    }
}

extension ItemParts {
    var preferredURLString: String {
        resolvedUrl ?? givenUrl
    }
}

extension Item {
    typealias RemoteSavedItem = UserByTokenQuery.Data.UserByToken.SavedItem.Edge.Node
    typealias RemoteItem = ItemParts

    func update(from savedItem: RemoteSavedItem) {
        itemID = savedItem.itemId
        isArchived = savedItem.isArchived
        url = URL(string: savedItem.preferredURLString)
        isFavorite = savedItem.isFavorite
        timestamp = Date(timeIntervalSince1970: TimeInterval(savedItem._createdAt))
        deletedAt = savedItem._deletedAt
            .flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }

        update(from: savedItem.item.fragments.itemParts)
    }

    func update(from item: RemoteItem?) {
        guard let item = item else {
            return
        }

        domain = item.domain
        language = item.language
        title = item.title
        particleJSON = item.particleJson

        if let context = managedObjectContext {
            domainMetadata = DomainMetadata(context: context)
            domainMetadata?.name = item.domainMetadata?.name
        }

        if let imageURL = item.topImageUrl {
            thumbnailURL = URL(string: imageURL)
        }

        if let time = item.timeToRead {
            timeToRead = Int32(time)
        }
    }

    public var particle: Article? {
        return particleJSON?.data(using: .utf8).flatMap { data in
            let decoder = JSONDecoder()
            return try? decoder.decode(Article.self, from: data)
        }
    }
}
