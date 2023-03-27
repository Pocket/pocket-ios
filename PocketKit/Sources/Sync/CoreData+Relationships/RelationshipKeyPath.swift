// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData

/// Describes a relationship key path for a Core Data entity.
public struct RelationshipKeyPath: Hashable {
    /// The source property name of the relationship entity we're observing.
    let sourcePropertyName: String

    let destinationEntityName: String

    /// The destination property name we're observing
    let destinationPropertyName: String

    /// The inverse property name of this relationship. Can be used to get the affected object IDs.
    let inverseRelationshipKeyPath: String

    public init(keyPath: String, relationships: [String: NSRelationshipDescription]) {
        let splittedKeyPath = keyPath.split(separator: ".")

        if splittedKeyPath.count == 2 {
            // Original code from https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/ to monitor 1 level deep of relationships
            sourcePropertyName = String(splittedKeyPath.first!)
            destinationPropertyName = String(splittedKeyPath.last!)
            let relationship = relationships[sourcePropertyName]!
            destinationEntityName = relationship.destinationEntity!.name!
            inverseRelationshipKeyPath = relationship.inverseRelationship!.name
        } else if splittedKeyPath.count == 3 {
            // Modified code to monitor 2 level deep of relationships.
            // There is probaly a better way to do this with recursion and supporting more layers, but right now we only need 2, and, well, this works. 😅

            let firstPropertyName = String(splittedKeyPath.first!)
            sourcePropertyName = String(splittedKeyPath[1])

            let relationship = relationships[firstPropertyName]!
            let firstInverseKeyPath = relationship.inverseRelationship!.name

            guard let secondRelationships = relationship.inverseRelationship?.entity.relationshipsByName else {
                fatalError("Developer error, you should have a relationship if you are monitoring this path")
            }

            let secondRelationship = secondRelationships[sourcePropertyName]!

            destinationPropertyName = String(splittedKeyPath.last!)
            destinationEntityName = secondRelationship.destinationEntity!.name!
            inverseRelationshipKeyPath = "\(secondRelationship.inverseRelationship!.name).\(firstInverseKeyPath)"
        } else {
            // Developer error trying to monitor more then 2 levels deep of nesting of relationships. See comment above.
            fatalError("We only support observing 2 levels of nesting")
        }

        [sourcePropertyName, destinationEntityName, destinationPropertyName].forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }
}
