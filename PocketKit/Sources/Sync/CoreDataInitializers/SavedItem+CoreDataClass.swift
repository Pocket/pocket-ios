// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
import Foundation
import CoreData

@objc(SavedItem)
public class SavedItem: NSManagedObject {
    @available(*, unavailable)
    public init() {
        fatalError()
    }

    @available(*, unavailable)
    public init(context: NSManagedObjectContext) {
        fatalError()
    }

    public init(
        context: NSManagedObjectContext,
        url: URL,
        remoteID: String? = nil
    ) {
        let entity = NSEntityDescription.entity(forEntityName: "SavedItem", in: context)!
        super.init(entity: entity, insertInto: context)
        self.url = url
        self.remoteID = remoteID
    }
}
