// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
import Foundation
import CoreData

@objc(CDSlate)
public class CDSlate: NSManagedObject {
    @available(*, unavailable)
    public init() {
        fatalError()
    }

    @available(*, unavailable)
    public init(context: NSManagedObjectContext) {
        fatalError()
    }

    internal override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public init(
        context: NSManagedObjectContext,
        remoteID: String,
        expermimentID: String,
        requestID: String
    ) {
        let entity = NSEntityDescription.entity(forEntityName: "Slate", in: context)!
        super.init(entity: entity, insertInto: context)
        self.remoteID = remoteID
        self.experimentID = expermimentID
        self.requestID = requestID
    }
}
