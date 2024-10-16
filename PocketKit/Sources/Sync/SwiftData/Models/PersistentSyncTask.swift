// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class PersistentSyncTask {
    public var createdAt: Date? = Date(timeIntervalSinceReferenceDate: 666643260.000000)
    public var currentCursor: String?
    @Attribute(.transformable(by: SyncTaskTransformer.self))
    public var syncTaskContainer: SyncTaskContainer?
    public init(syncTaskContainer: SyncTaskContainer) {
        self.syncTaskContainer = syncTaskContainer
    }
}
