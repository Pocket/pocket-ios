import BackgroundTasks
import Sync
import UIKit
import Combine

class RefreshCoordinator {
    static let taskID = "com.mozilla.pocket.next.refresh"

    private let notificationCenter: NotificationCenter
    private let taskScheduler: BGTaskSchedulerProtocol
    private let source: Source
    private let sessionProvider: SessionProvider

    private var subscriptions: [AnyCancellable] = []

    init(
        notificationCenter: NotificationCenter,
        taskScheduler: BGTaskSchedulerProtocol,
        source: Source,
        sessionProvider: SessionProvider
    ) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.source = source
        self.sessionProvider = sessionProvider
    }

    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: Self.taskID, using: .global(qos: .background)) { [weak self] task in
            self?.refresh(task)
            self?.submitRequest()
        }

        notificationCenter.publisher(for: UIScene.didEnterBackgroundNotification, object: nil).sink { [weak self] _ in
            self?.submitRequest()
        }.store(in: &subscriptions)

        notificationCenter.publisher(for: UIScene.willEnterForegroundNotification, object: nil).sink { [weak self] _ in
            self?.refreshData()
        }.store(in: &subscriptions)
    }

    private func refreshData() {
        guard (sessionProvider.session) != nil else {
            Log.info("Not refreshing saves & archive data because no active session")
            return
        }
        self.source.refreshSaves()
        self.source.refreshArchive()
        self.source.resolveUnresolvedSavedItems()
    }

    private func submitRequest() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "com.mozilla.pocket.next.refresh")
            request.earliestBeginDate = Date() + 60 * 5

            try taskScheduler.submit(request)
        } catch {
            Log.capture(error: error)
        }
    }

    private func refresh(_ task: BGTaskProtocol) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        source.refreshSaves {
            task.setTaskCompleted(success: true)
        }
    }
}
