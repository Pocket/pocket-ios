import Combine


enum SyncOperationResult {
    case retry(Error)
    case success
    case failure(Error)
}

protocol SyncOperation {
    func execute() async -> SyncOperationResult
}

class RetriableOperation: AsyncOperation {
    typealias RetrySignal = AnyPublisher<Void, Never>

    enum Status {
        case failed
        case retry
        case success
    }

    private let operation: SyncOperation
    private let retrySignal: RetrySignal
    private let backgroundTaskManager: BackgroundTaskManager
    private var retries = 0
    private var subscription: AnyCancellable?

    init(
        retrySignal: RetrySignal,
        backgroundTaskManager: BackgroundTaskManager,
        operation: SyncOperation
    ) {
        self.retrySignal = retrySignal
        self.backgroundTaskManager = backgroundTaskManager
        self.operation = operation
    }

    override func main() {
        Task {
            let taskID = backgroundTaskManager.beginTask()
            switch await operation.execute() {
            case .retry(let error):
                retry(error)
            case .failure(let error):
                Crashlogger.capture(message: "Retriable operation \"\(operation)\" failed")
                Crashlogger.capture(error: error)
                finishOperation()
            case .success:
                finishOperation()
            }
            backgroundTaskManager.endTask(taskID)
        }
    }

    private func retry(_ error: Error?) {
        subscription = retrySignal.sink { [weak self] in
            self?._retry(error)
        }
    }

    private func _retry(_ error: Error?) {
        guard retries < 2 else {
            Crashlogger.capture(message: "Retriable operation \"\(operation)\" exceeded maximum number of retries")
            if let error = error {
                Crashlogger.capture(error: error)
            }

            finishOperation()
            return
        }

        retries += 1
        main()
    }
}
