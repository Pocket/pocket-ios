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
