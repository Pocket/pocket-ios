// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData


extension SavedItem {
    typealias RemoteSavedItem = SavedItemParts
    typealias RemoteItem = ItemParts

    func update(from remote: RemoteSavedItem) {
        remoteID = remote.remoteId
        url = URL(string: remote.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(remote._createdAt))
        deletedAt = remote._deletedAt.flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        isArchived = remote.isArchived
        isFavorite = remote.isFavorite

        guard let itemParts = remote.item.fragments.itemParts,
              let context = managedObjectContext else {
                  return
              }

        item = item ?? Item(context: context)
        item?.update(remote: itemParts)
    }
}

extension Item {
    func update(remote: ItemParts) {
        remoteID = remote.remoteId
        givenURL = URL(string: remote.givenUrl)
        resolvedURL = remote.resolvedUrl.flatMap(URL.init)
        title = remote.title
        topImageURL = remote.topImageUrl.flatMap(URL.init)
        domain = remote.domain
        language = remote.language
        timeToRead = remote.timeToRead.flatMap(Int32.init) ?? 0
        particleJSON = remote.particleJson
        excerpt = remote.excerpt

        guard let domainParts = remote.domainMetadata?.fragments.domainMetadataParts,
              let context = managedObjectContext else {
                  return
              }

        domainMetadata = domainMetadata ?? DomainMetadata(context: context)
        domainMetadata?.update(remote: domainParts)
    }
}

extension DomainMetadata {
    func update(remote: DomainMetadataParts) {
        name = remote.name
        logo = remote.logo.flatMap(URL.init)
    }
}
