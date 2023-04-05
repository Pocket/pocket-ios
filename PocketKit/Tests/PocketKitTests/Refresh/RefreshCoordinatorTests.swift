import XCTest
import BackgroundTasks

@testable import Sync
@testable import PocketKit
import SharedPocketKit

class TestAbstractRefreshCoordinator: AbstractRefreshCoordinator {

    override var taskID: String! {
        get { return  "com.mozilla.pocket.refresh.test" }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    override var refreshInterval: TimeInterval! {
        get { return  60 * 60 }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    private let testCompletion: () -> Void

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, testCompletion: @escaping () -> Void) {
        self.testCompletion = testCompletion
        super.init(notificationCenter: notificationCenter, taskScheduler: taskScheduler, appSession: appSession)
    }

    override func refresh(completion: @escaping () -> Void) {
        super.refresh(completion: completion)
        completion()
        testCompletion()
    }
}

class AbstractRefreshCoordinatorTests: XCTestCase {
    var notificationCenter: NotificationCenter!
    var taskScheduler: MockBGTaskScheduler!
    var source: MockSource!
    var session: SharedPocketKit.Session!
    var appSession: AppSession!

    override func setUp() {
        notificationCenter = NotificationCenter()
        taskScheduler = MockBGTaskScheduler()
        source = MockSource()
        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        session = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        appSession.currentSession = session
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        taskScheduler: BGTaskSchedulerProtocol? = nil,
        source: Source? = nil,
        appSession: AppSession? = nil,
        completion: @escaping () -> Void
    ) -> TestAbstractRefreshCoordinator {
        TestAbstractRefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            taskScheduler: taskScheduler ?? self.taskScheduler,
            appSession: appSession ?? self.appSession,
            testCompletion: completion
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
