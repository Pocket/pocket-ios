import BackgroundTasks
import Sync
import UIKit
import Combine

protocol AbstractRefreshCoordinatorProtocol {

    func initialize()

    func refresh(completion: (() -> Void)?)

    func handleBackgroundRefresh(_ task: BGTaskProtocol)
}

extension AbstractRefreshCoordinatorProtocol {
    var taskID: String {
        fatalError("implement taskID")
    }

    var refreshInterval: TimeInterval {
        fatalError("implement refreshInterval")
    }
}

class AbstractRefreshCoordinator: AbstractRefreshCoordinatorProtocol {

    private let notificationCenter: NotificationCenter
    private let taskScheduler: BGTaskSchedulerProtocol
    private let sessionProvider: SessionProvider

    private var subscriptions: [AnyCancellable] = []

    init(
        notificationCenter: NotificationCenter,
        taskScheduler: BGTaskSchedulerProtocol,
        sessionProvider: SessionProvider
    ) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.sessionProvider = sessionProvider
    }

    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: taskID, using: .global(qos: .background)) { [weak self] task in
            self?.handleBackgroundRefresh(task)
            self?.submitRequest()
        }

        notificationCenter.publisher(for: UIScene.didEnterBackgroundNotification, object: nil).sink { [weak self] _ in
            self?.submitRequest()
        }.store(in: &subscriptions)

        notificationCenter.publisher(for: UIScene.willEnterForegroundNotification, object: nil).sink { [weak self] _ in
            self?.refresh()
        }.store(in: &subscriptions)

        // TODO: add in logout/login handling
    }

    internal func refresh(completion: (() -> Void)? = nil) {
        guard (sessionProvider.session) != nil else {
            Log.info("Not refreshing \(Self.Type.self) because no active session")
            return
        }

//        self.source.refreshArchive()
//        self.source.refreshTags()
//        self.source.resolveUnresolvedSavedItems()
    }

    private func submitRequest() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskID)
            request.earliestBeginDate = Date().addingTimeInterval(refreshInterval)

            try taskScheduler.submit(request)
        } catch {
            Log.capture(error: error)
        }
    }

    internal func handleBackgroundRefresh(_ task: BGTaskProtocol) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        self.refresh {
            task.setTaskCompleted(success: true)
        }
    }
}
