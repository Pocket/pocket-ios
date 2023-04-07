// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

/// A type that handles bulk saving operations on saved or archived items
struct SavedItemSpace {
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

    func savePage(edges: [SavedItem.SavedItemEdge?], cursor: String) throws {
        for edge in edges {
            guard let edge = edge, let node = edge.node, let url = URL(string: node.url) else {
                return
            }

            Log.breadcrumb(
                category: "sync",
                level: .info,
                message: "Updating/Inserting SavedItem with ID: \(node.remoteID)"
            )

            context.performAndWait {
                let item = (try? space.fetchSavedItem(byRemoteID: node.remoteID, context: context)) ?? SavedItem(context: context, url: url, remoteID: node.remoteID)
                item.update(from: edge, with: space)

                if item.deletedAt != nil {
                    space.delete(item, in: context)
                }
                task.currentCursor = cursor
            }

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
}
