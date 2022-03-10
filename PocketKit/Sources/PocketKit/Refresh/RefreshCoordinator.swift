import BackgroundTasks
import Sync
import UIKit
import Combine


class RefreshCoordinator {
    static let taskID = "com.mozilla.pocket.next.refresh"

    private let notificationCenter: NotificationCenter
    private let taskScheduler: BGTaskSchedulerProtocol
    private let source: Source

    private var subscriptions: [AnyCancellable] = []

    init(
        notificationCenter: NotificationCenter,
        taskScheduler: BGTaskSchedulerProtocol,
        source: Source
    ) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.source = source
    }

    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: Self.taskID, using: .main) { [weak self] task in
            self?.refresh(task)
            self?.submitRequest()
        }

        notificationCenter.publisher(for: UIScene.didEnterBackgroundNotification, object: nil).sink { [weak self] _ in
            self?.submitRequest()
        }.store(in: &subscriptions)

        notificationCenter.publisher(for: UIScene.willEnterForegroundNotification, object: nil).sink { [weak self] _ in
            self?.source.refresh()
        }.store(in: &subscriptions)
    }

    private func submitRequest() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "com.mozilla.pocket.next.refresh")
            request.earliestBeginDate = Date() + 60 * 5

            try taskScheduler.submit(request)
        } catch {
            print(error)
        }
    }

    private func refresh(_ task: BGTaskProtocol) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        source.refresh() {
            task.setTaskCompleted(success: true)
        }
    }
}
