import XCTest
import BackgroundTasks

@testable import Sync
@testable import PocketKit

class RefreshCoordinatorTests: XCTestCase {
    var notificationCenter: NotificationCenter!
    var taskScheduler: MockBGTaskScheduler!
    var source: MockSource!
    var sessionProvider: MockSessionProvider!

    override func setUp() {
        notificationCenter = NotificationCenter()
        taskScheduler = MockBGTaskScheduler()
        source = MockSource()
        sessionProvider = MockSessionProvider(session: MockSession())
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        taskScheduler: BGTaskSchedulerProtocol? = nil,
        source: Source? = nil,
        sessionProvider: MockSessionProvider? = nil
    ) -> RefreshCoordinator {
        RefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            taskScheduler: taskScheduler ?? self.taskScheduler,
            source: source ?? self.source,
            sessionProvider: sessionProvider ?? self.sessionProvider
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

        source.stubRefreshSaves { completion in
            completion?()
        }

        let coordinator = subject()
        coordinator.initialize()

        // invoke handler (simulating what the OS would normally do)
        let task = MockBGTask()
        task.stubSetTaskCompleted { _ in }
        handler?(task)

        XCTAssertNotNil(source.refreshSavesCall(at: 0))
        XCTAssertNotNil(task.setTaskCompletedCall(at: 0))
    }

    func test_backgroundTaskHandler_whenExpirationHappens_completesTask() {
        // Setup task scheduler to capture the task handler so we can invoke it later
        var handler: ((BGTaskProtocol) -> Void)?
        taskScheduler.stubRegisterHandler { handler = $2; return true }
        taskScheduler.stubSubmit { _ in }

        source.stubRefreshSaves { completion in
            // completion callback never fires
        }

        let coordinator = subject()
        coordinator.initialize()

        // invoke handler (simulating what the OS would normally do)
        let task = MockBGTask()
        task.stubSetTaskCompleted { _ in }
        handler?(task)

        task.expirationHandler?()

        XCTAssertNotNil(source.refreshSavesCall(at: 0))
        XCTAssertNotNil(task.setTaskCompletedCall(at: 0))
        XCTAssertEqual(task.setTaskCompletedCall(at: 0)?.success, false)
    }

    func test_receivingAppWillEnterForegroundNotification_refreshesSource_andResolvesUnresolvedSavedItems() {
        taskScheduler.stubRegisterHandler { _, _, _ in true }
        source.stubRefreshSaves { _ in }
        source.stubRefreshTags { _ in }
        source.stubRefreshArchive { _ in }
        source.stubResolveUnresolvedSavedItems { }

        let coordinator = subject()
        coordinator.initialize()

        notificationCenter?.post(name: UIScene.willEnterForegroundNotification, object: nil)

        XCTAssertNotNil(source.refreshSavesCall(at: 0))
        XCTAssertNotNil(source.resolveUnresolvedSavedItemsCall(at: 0))
        XCTAssertNotNil(source.refreshArchiveCall(at: 0))
    }

    func test_coordinator_whenNoSession_doesNotRefreshSavesArchive() {
        source.stubRefreshSaves {  _ in
            XCTFail("Should not fetch saves")
        }
        source.stubRefreshArchive { _ in
            XCTFail("Should not fetch archive")
        }
        source.stubResolveUnresolvedSavedItems {
            XCTFail("Should not resolve items")
        }

        let coordinator = subject(sessionProvider: MockSessionProvider(session: nil))
        XCTAssertNil(source.refreshSavesCall(at: 0))
        XCTAssertNil(source.resolveUnresolvedSavedItemsCall(at: 0))
        XCTAssertNil(source.refreshArchiveCall(at: 0))
        XCTAssertNil(source.refreshTagsCall(at: 0))
    }
}
