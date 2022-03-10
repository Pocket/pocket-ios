import XCTest
import BackgroundTasks

@testable import Sync
@testable import PocketKit


class RefreshCoordinatorTests: XCTestCase {
    var notificationCenter: NotificationCenter!
    var taskScheduler: MockBGTaskScheduler!
    var source: MockSource!

    override func setUp() {
        notificationCenter = NotificationCenter()
        taskScheduler = MockBGTaskScheduler()
        source = MockSource()
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        taskScheduler: BGTaskSchedulerProtocol? = nil,
        source: Source? = nil
    ) -> RefreshCoordinator {
        RefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            taskScheduler: taskScheduler ?? self.taskScheduler,
            source: source ?? self.source
        )
    }

    func test_initialize_registersTheBackgroundTask() {
        taskScheduler.stubRegisterHandler { _, _, _ in return true }

        let coordinator = subject()
        coordinator.initialize()

        let registerCall = taskScheduler.registerHandlerCall(at: 0)
        XCTAssertNotNil(registerCall)
        XCTAssertEqual(registerCall?.identifier, RefreshCoordinator.taskID)
    }

    func test_receivingAppDidEnterBackgroundNotification_submitsBGAppRefreshRequest() {
        taskScheduler.stubRegisterHandler { _, _, _ in return true }
        taskScheduler.stubSubmit { _ in }

        let coordinator = subject()
        coordinator.initialize()
        notificationCenter?.post(name: UIScene.didEnterBackgroundNotification, object: nil)

        let submitCall = taskScheduler.submitCall(at: 0)
        XCTAssertNotNil(submitCall)
        XCTAssertTrue(submitCall?.taskRequest is BGAppRefreshTaskRequest)
        XCTAssertEqual(submitCall?.taskRequest.identifier, RefreshCoordinator.taskID)
    }

    func test_backgroundTaskHandler_beginsBackgroundtask_callsRefresh_completsBackgroundTask_completesRefreshTask() {
        // Setup task scheduler to capture the task handler so we can invoke it later
        var handler: ((BGTaskProtocol) -> Void)?
        taskScheduler.stubRegisterHandler { handler = $2; return true }
        taskScheduler.stubSubmit { _ in }

        source.stubRefresh { _, completion in
            completion?()
        }

        let coordinator = subject()
        coordinator.initialize()

        // invoke handler (simulating what the OS would normally do)
        let task = MockBGTask()
        task.stubSetTaskCompleted { _ in }
        handler?(task)

        XCTAssertNotNil(source.refreshCall(at:0))
        XCTAssertNotNil(task.setTaskCompletedCall(at:0))
    }

    func test_backgroundTaskHandler_whenExpirationHappens_completesTask() {
        // Setup task scheduler to capture the task handler so we can invoke it later
        var handler: ((BGTaskProtocol) -> Void)?
        taskScheduler.stubRegisterHandler { handler = $2; return true }
        taskScheduler.stubSubmit { _ in }

        source.stubRefresh { _, completion in
            // completion callback never fires
        }

        let coordinator = subject()
        coordinator.initialize()

        // invoke handler (simulating what the OS would normally do)
        let task = MockBGTask()
        task.stubSetTaskCompleted { _ in }
        handler?(task)

        task.expirationHandler?()

        XCTAssertNotNil(source.refreshCall(at:0))
        XCTAssertNotNil(task.setTaskCompletedCall(at:0))
        XCTAssertEqual(task.setTaskCompletedCall(at:0)?.success, false)
    }

    func test_receivingAppWillEnterForegroundNotification() {
        taskScheduler.stubRegisterHandler { _, _, _ in true }
        source.stubRefresh { _, _ in }

        let coordinator = subject()
        coordinator.initialize()

        notificationCenter?.post(name: UIScene.willEnterForegroundNotification, object: nil)

        XCTAssertNotNil(source.refreshCall(at:0))
    }
}
