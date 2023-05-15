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

        guard let context = managedObjectContext else {
            Log.capture(message: "Managed context was nil")
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

        if let itemParts = remote.item.asItem?.fragments.itemParts {
            Log.breadcrumb(category: "sync", level: .debug, message: "Updating item parts for \(itemParts.remoteID)")

            let givenURL = itemParts.givenUrl
            let itemToUpdate = (try? space.fetchItem(byURL: givenURL, context: context)) ?? Item(context: context, givenURL: givenURL, remoteID: itemParts.remoteID)
            itemToUpdate.update(remote: itemParts, with: space)
            item = itemToUpdate
        } else if let pendingParts = remote.item.asPendingItem?.fragments.pendingItemParts {
            Log.breadcrumb(category: "sync", level: .debug, message: "Updating pending parts for \(pendingParts.remoteID)")

            let givenURL = pendingParts.givenUrl
            let itemToUpdate = (try? space.fetchItem(byURL: givenURL, context: context)) ?? Item(context: context, givenURL: givenURL, remoteID: pendingParts.remoteID)
            itemToUpdate.update(remote: pendingParts, with: space)
            item = itemToUpdate
        }
    }

    public func update(from recommendation: Recommendation) {
        let url = recommendation.item.givenURL
        self.url = URL(string: url)! // TODO: This should not be force unwrapped
        self.createdAt = Date()

        self.item = recommendation.item
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

        guard let context = managedObjectContext else {
            Log.capture(message: "Managed context was nil")
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

        if let itemSummary = summary.item.asItem?.fragments.itemSummary {
            Log.breadcrumb(category: "sync", level: .debug, message: "Updating item parts from summary for \(itemSummary.remoteID)")

            let givenURL = itemSummary.givenUrl
            let itemToUpdate = (try? space.fetchItem(byURL: givenURL, context: context)) ?? Item(context: context, givenURL: givenURL, remoteID: itemSummary.remoteID)
            itemToUpdate.update(from: itemSummary, with: space)
            item = itemToUpdate
        } else if let pendingParts = summary.item.asPendingItem?.fragments.pendingItemParts {
            Log.breadcrumb(category: "sync", level: .debug, message: "Updating pending parts from summary for \(pendingParts.remoteID)")

            let givenURL = pendingParts.givenUrl
            let itemToUpdate = (try? space.fetchItem(byURL: givenURL, context: context)) ?? Item(context: context, givenURL: givenURL, remoteID: pendingParts.remoteID)
            itemToUpdate.update(remote: pendingParts, with: space)
            item = itemToUpdate
        }
    }
}
