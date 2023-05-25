// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync
import CoreData

class TestSyncOperation: SyncOperation {
    private let block: () async -> SyncOperationResult

    init(block: @escaping () -> SyncOperationResult) {
        self.block = block
    }

    init(block: @escaping () -> Void) {
        self.block = {
            block()
            return .success
        }
    }

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        return await block()
    }
}
