// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDPersistentSyncTask {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDPersistentSyncTask> {
        return NSFetchRequest<CDPersistentSyncTask>(entityName: "PersistentSyncTask")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var currentCursor: String?
    @NSManaged public var syncTaskContainer: SyncTaskContainer?
}
