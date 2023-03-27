// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData

/// Observes relationship key paths and refreshes Core Data objects accordingly once the related managed object context saves.
public final class RelationshipKeyPathsObserver<ResultType: NSFetchRequestResult>: NSObject {
    private let keyPaths: Set<RelationshipKeyPath>
    private unowned let fetchedResultsController: RichFetchedResultsController<ResultType>

    private var updatedObjectIDs: Set<NSManagedObjectID> = []

    public init?(keyPaths: Set<String>, fetchedResultsController: RichFetchedResultsController<ResultType>) {
        guard !keyPaths.isEmpty else { return nil }

        let relationships = fetchedResultsController.fetchRequest.entity!.relationshipsByName
        self.keyPaths = Set(keyPaths.map { keyPath in
            return RelationshipKeyPath(keyPath: keyPath, relationships: relationships)
        })
        self.fetchedResultsController = fetchedResultsController

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChangeNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    @objc private func contextDidChangeNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }

        let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let deletedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let updatedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let objects = insertedObjects.union(deletedObjects).union(updatedObjects)

        context.performAndWait { [weak self] in
            guard let self else {
                return
            }
            guard let objectIDs = objects.updatedObjectIDs(for: keyPaths), !objectIDs.isEmpty else { return }
            self.updatedObjectIDs = self.updatedObjectIDs.union(objectIDs)
        }
    }

    /// Context saved, so take any pending objects that we are montiroing and trigger a refresh in their context.
    /// - Parameter notification: notification from NSNotificationCenter
    @objc private func contextDidSaveNotification(notification: NSNotification) {
        guard !updatedObjectIDs.isEmpty else { return }
        guard let fetchedObjects = fetchedResultsController.fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else { return }

        fetchedObjects.forEach { object in
            guard updatedObjectIDs.contains(object.objectID) else { return }
            fetchedResultsController.managedObjectContext.refresh(object, mergeChanges: true)
        }
        updatedObjectIDs.removeAll()
    }
}
