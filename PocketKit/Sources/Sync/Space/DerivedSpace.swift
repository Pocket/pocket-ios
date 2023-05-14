// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import SharedPocketKit
import PocketGraph

/// Protocol representing a type that exposes a (read only) task cursor
protocol Paginated {
    var currentCursor: String? { get }
}

/// Set of protocols that update a set of a specified entity in Core Data. Used to specialize `DerivedSpace` for that same entity.
protocol SavedItemSpace: Paginated {
    func updateSavedItems(edges: [SavedItem.SavedItemEdge?], cursor: String) throws
}

protocol ArchivedItemSpace: Paginated {
    func updateArchivedItems(edges: [SavedItem.ArchivedItemEdge?], cursor: String) throws
}

protocol TagSpace: Paginated {
    func updateTags(edges: [Tag.TagEdge?], cursor: String?) throws
}

protocol SharedWithYouSpace {
    func batchDeleteSharedWithYouHighlightsNotInArray(urls: [URL]) throws
    func updateSharedWithYouHighlight(highlight: PocketSWHighlight, with remoteParts: ItemSummary) throws
}

/// A type that handles save operations on paginated data,
/// using a child context derived from the `Space` instance
struct DerivedSpace {
    private let space: Space
    private let context: NSManagedObjectContext
    private let task: PersistentSyncTask

    var currentCursor: String? {
        task.currentCursor
    }

    init?(space: Space, taskID: NSManagedObjectID) {
        let context = space.makeChildBackgroundContext()

        var fetchedTask: PersistentSyncTask?
        context.performAndWait {
            fetchedTask = context.object(with: taskID) as? PersistentSyncTask

        }
        guard let task = fetchedTask else {
            return nil
        }
        self.space = space
        self.context = context
        self.task = task
    }

    private func logItemUpdated(itemID: String) {
        Log.breadcrumb(
            category: "sync",
            level: .info,
            message: "Updating/Inserting SavedItem with ID: \(itemID)"
        )
    }

    private func updateCursor(_ newCursor: String) {
        context.performAndWait {
            task.currentCursor = newCursor
        }
    }

    private func saveContexts() throws {
        // save the child context
        try context.performAndWait {
            guard context.hasChanges else {
                return
            }
            try context.save()
            // then save the parent context
            try space.save()
        }
    }
}

extension DerivedSpace: SavedItemSpace {
    func updateSavedItems(edges: [SavedItem.SavedItemEdge?], cursor: String) throws {
        updateCursor(cursor)
        for edge in edges {
            guard let edge = edge, let node = edge.node, let url = URL(string: node.url) else {
                return
            }

            logItemUpdated(itemID: node.remoteID)

            context.performAndWait {
                let item = (try? space.fetchSavedItem(byURL: url, context: context)) ?? SavedItem(context: context, url: url, remoteID: node.remoteID)
                item.update(from: edge, with: space)

                if item.deletedAt != nil {
                    space.delete(item, in: context)
                }
            }
        }

        try saveContexts()
    }
}

extension DerivedSpace: ArchivedItemSpace {
    func updateArchivedItems(edges: [SavedItem.ArchivedItemEdge?], cursor: String) throws {
        updateCursor(cursor)

        for edge in edges {
            guard let edge = edge, let node = edge.node, let url = URL(string: node.url) else {
                return
            }

            logItemUpdated(itemID: node.remoteID)

            context.performAndWait {
                let item = (try? space.fetchSavedItem(byURL: url, context: context)) ?? SavedItem(context: context, url: url, remoteID: node.remoteID)
                item.update(from: node.fragments.savedItemSummary, with: space)
                item.cursor = edge.cursor
                if item.deletedAt != nil {
                    space.delete(item, in: context)
                }
            }
        }
        try saveContexts()
    }
}

extension DerivedSpace: TagSpace {
    func updateTags(edges: [Tag.TagEdge?], cursor: String?) throws {
        if let cursor {
            updateCursor(cursor)
        }

        edges.forEach { edge in
            guard let node = edge?.node else { return }
            context.performAndWait {
                let tag = space.fetchOrCreateTag(byName: node.name, context: context)
                tag.update(remote: node.fragments.tagParts)
            }
        }
        try saveContexts()
    }
}

extension DerivedSpace: SharedWithYouSpace {

    func updateSharedWithYouHighlight(highlight: PocketSWHighlight, with remoteParts: ItemSummary) throws {
        guard let url = URL(string: remoteParts.givenUrl) else {
            return
        }

        context.performAndWait {
            let item = (try? space.fetchItem(byURL: url)) ?? Item(context: context, givenURL: url, remoteID: remoteParts.remoteID)
            item.update(from: remoteParts, with: space)
            _ = (try? space.fetchSharedWithYouHighlight(with: highlight.url, in: context)) ?? SharedWithYouHighlight(context: context, url: highlight.url, sortOrder: highlight.index, item: item)
        }
        try saveContexts()
    }

    /// Cleans up any shared wtih you highlights no longer in our snapshot handed to us by Apple
    /// - Parameter urls: <#urls description#>
    func batchDeleteSharedWithYouHighlightsNotInArray(urls: [URL]) throws {
        context.performAndWait {
            let fetchRequest = SharedWithYouHighlight.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "NOT %K IN %@", #keyPath(SharedWithYouHighlight.url), urls.map({ $0 as CVarArg }))

            guard let sharedWithYouHighlightsToDelete = try? context.fetch(fetchRequest) else {
                // Nothing to delete.
                return
            }

            sharedWithYouHighlightsToDelete.forEach { sharedWithYouHighlight in
                space.delete(sharedWithYouHighlight, in: context)
            }
        }
        try saveContexts()
    }
}
