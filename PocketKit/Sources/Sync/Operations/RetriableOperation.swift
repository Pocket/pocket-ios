// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import CoreData
import SharedPocketKit

enum SyncOperationResult {
    case retry(Error)
    case success
    case failure(Error)
}

struct NoPersistentTaskOperationError: Error { }

/// Protocol that all operations in the Pocket code base follows for syncing data
protocol SyncOperation {
    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult
}

/// A NSOperation that retries its operation thread if needed.
/// The code operates as follows:
///     - If the underlying SyncOperation returns a retryStatus code, the NSOperation will begin listening to a RetrySignal publisher (passed in)
///     - Wait to retry until it receives such signal.
///     - Retry up to 3 times
/// This class will also perform its main() logic using a BackgroundTask from UIApplication, so we also listen in case it will expire and in that case will cancel the whole operation
/// Once the operation finishes it will remove the PersistentSyncTask from CoreData so that it is not restored.
/// Because we hold the retries in memory and do not persist to disk there are scenarios where if a operation is marked to Retry, and the user backgrounds the app when they open the app the retry counter will be reset.
///    For now this is ok, because it is a way to manually tell the app to retry operations. In the future we may want to do more with Circuit Breakers and Exponential Backoffs
class RetriableOperation: AsyncOperation {
    typealias RetrySignal = AnyPublisher<Void, Never>

    private let operation: SyncOperation
    private let retrySignal: RetrySignal
    private let backgroundTaskManager: BackgroundTaskManager
    private let space: Space
    private let syncTaskId: NSManagedObjectID
    private var retries = 0
    private var subscription: AnyCancellable?

    init(
        retrySignal: RetrySignal,
        backgroundTaskManager: BackgroundTaskManager,
        operation: SyncOperation,
        space: Space,
        syncTaskId: NSManagedObjectID
    ) {
        self.retrySignal = retrySignal
        self.backgroundTaskManager = backgroundTaskManager
        self.operation = operation
        self.space = space
        self.syncTaskId = syncTaskId
    }

    /// Performs all the main work for this operation
    override func main() {
        /// Wrap the code in a Task so that it is Async, Apple by default does not provide an Async capable NSOperation.
        /// But they provide a variable to make one Async.
        /// See AsyncOperation which makes NSOperation Async
        Task { [weak self] in
            guard let self else {
                Log.captureNilWeakSelf()
                return
            }

            let taskID = backgroundTaskManager.beginTask(withName: String(describing: type(of: operation))) { [weak self] in
                guard let self else {
                    Log.captureNilWeakSelf()
                    return
                }
                cancelOperation()
            }

            switch await operation.execute(syncTaskId: self.syncTaskId) {
            case .retry(let error):
                Log.info("Retrying persistent task with objectID \(String(describing: syncTaskId)) due to \(String(describing: error))")
                retry(error)
            case .failure(let error):
                Log.warning("Failed persistent task with objectID \(String(describing: syncTaskId)) due to \(String(describing: error))")
                Log.capture(error: error)
                doneWithTask()
            case .success:
                Log.info("Successfully finished persistent task with objectID \(String(describing: syncTaskId))")
                doneWithTask()
            }
            backgroundTaskManager.endTask(taskID)
        }
    }

    /// Signals that we are done with the task and will perform all clean up operations
    private func doneWithTask() {
        clearPersistentTask()
        finishOperation()
    }

    /// Removes the persistent task from CoreData so that it is not executed again
    private func clearPersistentTask() {
        do {
            Log.info("Deleting persistent task with objectID \(self.syncTaskId)")
            guard let task = space.backgroundObject(with: syncTaskId) as? PersistentSyncTask else { return }
            space.delete(task)
            try space.save()
        } catch {
            Log.capture(error: error)
        }
    }

    /// Sets up a subscriber to listen for a RetrySignal
    /// - Parameter error: The error that the underlying operation sent
    private func retry(_ error: Error?) {
        subscription = retrySignal.sink { [weak self] in
            guard let self else {
                Log.captureNilWeakSelf()
                return
            }
            self._retry(error)
        }
    }

    /// Called when we recieve a signal to retry.
    /// - Parameter error: The error from the last run of the operation
    private func _retry(_ error: Error?) {
        guard retries < 2 else {
            Log.breadcrumb(
                category: "sync",
                level: .error,
                message: "Retriable operation \"\(operation)\" exceeded maximum number of retries"
            )

            if let error {
                Log.capture(error: error)
            }

            doneWithTask()
            return
        }

        retries += 1
        main()
    }
}
