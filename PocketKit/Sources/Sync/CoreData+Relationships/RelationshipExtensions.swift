// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData

extension Set where Element: NSManagedObject {
    /// Iterates over the objects and returns the object IDs that matched our observing keyPaths.
    /// - Parameter keyPaths: The keyPaths to observe changes for.
    func updatedObjectIDs(for keyPaths: Set<RelationshipKeyPath>) -> Set<NSManagedObjectID>? {
        var objectIDs: Set<NSManagedObjectID> = []
        forEach { object in
            guard let changedRelationshipKeyPath = object.changedKeyPath(from: keyPaths) else { return }

            let splitKeys = changedRelationshipKeyPath.inverseRelationshipKeyPath.split(separator: ".")
            var value = object.value(forKey: String(splitKeys.first!))

            // Loop through inverse relationship until we hit the root object we are observing
            splitKeys.dropFirst().forEach { keyPath in
                guard let object = value as? NSManagedObject else {
                    Log.warning("Updated object is not a NSManagedObject")
                    return
                }

                value = object.value(forKey: String(keyPath))
            }

            if let toManyObjects = value as? Set<NSManagedObject> {
                toManyObjects.forEach {
                    objectIDs.insert($0.objectID)
                }
            } else if let toOneObject = value as? NSManagedObject {
                objectIDs.insert(toOneObject.objectID)
            } else {
                return
            }
        }

        return objectIDs
    }
}

private extension NSManagedObject {
    /// Matches the given key paths to the current changes of this `NSManagedObject`.
    /// - Parameter keyPaths: The key paths to match the changes for.
    /// - Returns: The matching relationship key path if found. Otherwise, `nil`.
    func changedKeyPath(from keyPaths: Set<RelationshipKeyPath>) -> RelationshipKeyPath? {
        return keyPaths.first { keyPath -> Bool in
            guard keyPath.destinationEntityName == entity.name! || keyPath.destinationEntityName == entity.superentity?.name else { return false }
            return changedValues().keys.contains(keyPath.destinationPropertyName)
        }
    }
}
