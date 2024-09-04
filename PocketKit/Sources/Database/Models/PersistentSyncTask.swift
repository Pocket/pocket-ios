// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

// Not using yet while we still use CoreData since PersistentSync Task is not used in UI
// and we need to figure out the SyncTaskContainer
// @available(iOS 17, *)
// @Model public class PersistentSyncTask {
//    var createdAt: Date? = Date(timeIntervalSinceReferenceDate: 666643260.000000)
//    var currentCursor: String?
//    @Attribute(.transformable(by: "SyncTaskTransformer")) var syncTaskContainer: SyncTaskContainer
//    public init(syncTaskContainer: SyncTaskContainer) {
//        self.syncTaskContainer = syncTaskContainer
//    }
// }
