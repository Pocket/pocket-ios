// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import PocketGraph
import SharedPocketKit

extension SavedItem {
    typealias SavedItemEdge = FetchSavesQuery.Data.User.SavedItems.Edge
    typealias ArchivedItemEdge = FetchArchiveQuery.Data.User.SavedItems.Edge
    public typealias RemoteSavedItem = SavedItemParts
    typealias RemoteItem = ItemParts

    func update(from edge: SavedItemEdge, with space: Space) {
        cursor = edge.cursor

        guard let savedItemParts = edge.node?.fragments.savedItemParts else {
            return
        }

        update(from: savedItemParts, with: space)
    }

    public func update(from remote: RemoteSavedItem, with space: Space) {
        remoteID = remote.remoteID

        guard let url = URL(string: remote.url) else {
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of SavedItem \(remoteID) because \(remote.url) is not valid url")
            return
        }

        self.url = url
        createdAt = Date(timeIntervalSince1970: TimeInterval(remote._createdAt))
        deletedAt = remote._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = remote.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = remote.isArchived
        isFavorite = remote.isFavorite

        guard let context = managedObjectContext,
              let itemParts = remote.item.asItem?.fragments.itemParts,
              let itemUrl = URL(string: itemParts.givenUrl)
        else {
            return
        }

        if let tags = tags {
            removeFromTags(tags)
        }

        tags = NSOrderedSet(array: remote.tags?.compactMap { $0 }.map { remoteTag in
            let fetchedTag = space.fetchOrCreateTag(byName: remoteTag.name, context: context)
            fetchedTag.update(remote: remoteTag.fragments.tagParts)
            return fetchedTag
        } ?? [])

        let itemToUpdate = (try? space.fetchItem(byRemoteID: itemParts.remoteID, context: context)) ?? Item(context: context, givenURL: itemUrl, remoteID: itemParts.remoteID)
        itemToUpdate.update(remote: itemParts, with: space)
        item = itemToUpdate
    }

    public func update(from recommendation: Recommendation) {
        guard let url = recommendation.item.bestURL else {
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of Recommendation \(recommendation.remoteID) from SavedItem \(self.remoteID). Reason: item and/or url is invalid.")
            return
        }

        self.url = url
        self.createdAt = Date()

        self.item = item
    }

    public func update(from summary: SavedItemSummary, with space: Space) {
        remoteID = summary.remoteID
        guard let url = URL(string: summary.url) else {
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of SavedItem \(remoteID) because \(summary.url) is not valid url")
            return
        }

        self.url = url
        createdAt = Date(timeIntervalSince1970: TimeInterval(summary._createdAt))
        deletedAt = summary._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = summary.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = summary.isArchived
        isFavorite = summary.isFavorite

        guard let context = managedObjectContext,
              let itemSummary = summary.item.asItem?.fragments.itemSummary,
              let itemUrl =  URL(string: itemSummary.givenUrl)
        else {
            return
        }

        if let tags = tags {
            removeFromTags(tags)
        }

        tags = NSOrderedSet(array: summary.tags?.compactMap { $0 }.map { summaryTag in
            let tag = space.fetchOrCreateTag(byName: summaryTag.name, context: context)
            tag.update(remote: summaryTag.fragments.tagParts)
            return tag
        } ?? [])

        let itemToUpdate = (try? space.fetchItem(byRemoteID: itemSummary.remoteID, context: context)) ?? Item(context: context, givenURL: itemUrl, remoteID: itemSummary.remoteID)
        itemToUpdate.update(from: itemSummary, with: space)
        item = itemToUpdate
    }
}
