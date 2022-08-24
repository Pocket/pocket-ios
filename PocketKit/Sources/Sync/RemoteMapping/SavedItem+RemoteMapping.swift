// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData


extension SavedItem {
    typealias SavedItemEdge = UserByTokenQuery.Data.UserByToken.SavedItem.Edge
    public typealias RemoteSavedItem = SavedItemParts
    typealias RemoteItem = ItemParts

    func update(from edge: SavedItemEdge) {
        cursor = edge.cursor

        guard let savedItemParts = edge.node?.fragments.savedItemParts else {
            return
        }

        update(from: savedItemParts)
    }

    public func update(from remote: RemoteSavedItem) {
        remoteID = remote.remoteId
        url = URL(string: remote.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(remote._createdAt))
        deletedAt = remote._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = remote.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = remote.isArchived
        isFavorite = remote.isFavorite

        guard let context = managedObjectContext,
            let itemParts = remote.item.fragments.itemParts else {
            return
        }
        
        if let tags = tags {
            removeFromTags(tags)
        }
        
        remote.tags?.compactMap { $0 }.forEach({ remoteTag in
            let fetchRequest = Requests.fetchTag(byName: remoteTag.name)
            fetchRequest.fetchLimit = 1
            let tag = try? context.fetch(fetchRequest).first ?? Tag(context: context)
            
            guard let tag = tag else { return }
            tag.update(remote: remoteTag)
            addToTags(tag)
        })
        
        let fetchRequest = Requests.fetchItem(byRemoteID: itemParts.remoteId)
        fetchRequest.fetchLimit = 1
        let itemToUpdate = try? context.fetch(fetchRequest).first ?? Item(context: context)
        itemToUpdate?.update(remote: itemParts)
        item = itemToUpdate
    }

    public func update(from recommendation: Recommendation) {
        self.url = recommendation.item?.bestURL
        self.createdAt = Date()

        item = recommendation.item
    }

    public func update(from summary: SavedItemSummary) {
        remoteID = summary.remoteId
        url = URL(string: summary.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(summary._createdAt))
        deletedAt = summary._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = summary.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = summary.isArchived
        isFavorite = summary.isFavorite

        guard let context = managedObjectContext,
              let itemSummary = summary.item.fragments.itemSummary else {
            return
        }

        let fetchRequest = Requests.fetchItem(byRemoteID: itemSummary.remoteId)
        fetchRequest.fetchLimit = 1
        let itemToUpdate = try? context.fetch(fetchRequest).first ?? Item(context: context)
        itemToUpdate?.update(from: itemSummary)
        item = itemToUpdate
    }
}
