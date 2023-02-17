// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import PocketGraph

extension SavedItem {
    typealias SavedItemEdge = FetchSavesQuery.Data.UserByToken.SavedItems.Edge
    public typealias RemoteSavedItem = SavedItemReaderView
    typealias RemoteItem = ItemReaderView

    func update(from edge: SavedItemEdge, with space: Space) {
        cursor = edge.cursor

        guard let savedItemReaderView = edge.node?.fragments.savedItemReaderView else {
            return
        }

        update(from: savedItemReaderView, with: space)
    }

    public func update(from remote: RemoteSavedItem, with space: Space) {
        remoteID = remote.remoteID
        url = URL(string: remote.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(remote._createdAt))
        deletedAt = remote._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = remote.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = remote.isArchived
        isFavorite = remote.isFavorite

        guard let context = managedObjectContext,
              let itemReaderView = remote.item.asItem?.fragments.itemReaderView else {
            return
        }

        if let tags = tags {
            removeFromTags(tags)
        }

        tags = NSOrderedSet(array: remote.tags?.compactMap { $0 }.map { remoteTag in
            let fetchedTag = space.fetchOrCreateTag(byName: remoteTag.name)
            fetchedTag.update(remote: remoteTag.fragments.tagParts)
            return fetchedTag
        } ?? [])

        let fetchRequest = Requests.fetchItem(byRemoteID: itemReaderView.remoteID)
        fetchRequest.fetchLimit = 1
        let itemToUpdate = try? context.fetch(fetchRequest).first ?? Item(context: context)
        itemToUpdate?.update(remote: itemReaderView)
        item = itemToUpdate
    }

    public func update(from recommendation: Recommendation) {
        self.url = recommendation.item?.bestURL
        self.createdAt = Date()

        item = recommendation.item
    }

    public func update(from summary: SavedItemSummaryView, with space: Space) {
        remoteID = summary.remoteID
        url = URL(string: summary.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(summary._createdAt))
        deletedAt = summary._deletedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        archivedAt = summary.archivedAt.flatMap(TimeInterval.init).flatMap(Date.init(timeIntervalSince1970:))
        isArchived = summary.isArchived
        isFavorite = summary.isFavorite

        guard let context = managedObjectContext,
              let itemSummaryView = summary.item.asItem?.fragments.itemSummaryView else {
            return
        }

        if let tags = tags {
            removeFromTags(tags)
        }

        tags = NSOrderedSet(array: summary.tags?.compactMap { $0 }.map { summaryTag in
            space.fetchOrCreateTag(byName: summaryTag.name)
        } ?? [])

        let fetchRequest = Requests.fetchItem(byRemoteID: itemSummaryView.remoteID)
        fetchRequest.fetchLimit = 1
        let itemToUpdate = try? context.fetch(fetchRequest).first ?? Item(context: context)
        itemToUpdate?.update(from: itemSummaryView)
        item = itemToUpdate
    }
}
