import Combine
import BackgroundTasks


class RefreshCoordinator {
    private static let taskID = "com.mozilla.pocket.next.fetch-slate-lineup"

    var tasksPublisher: AnyPublisher<BGTask, Never> {
        return tasks.eraseToAnyPublisher()
    }

    private var tasks: PassthroughSubject<BGTask, Never> = PassthroughSubject()
    private let taskScheduler: BGTaskScheduler

    init(taskScheduler: BGTaskScheduler) {
        self.taskScheduler = taskScheduler
    }

    func initialize() {
        taskScheduler.register(forTaskWithIdentifier: Self.taskID, using: .main) { [weak self] task in
            self?.submitRequest()
            self?.tasks.send(task)
            task.setTaskCompleted(success: true)
        }

        submitRequest()
    }

    func submitRequest() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskID)

        do {
            try taskScheduler.submit(request)
        } catch {
            print(error)
        }
    }
}
