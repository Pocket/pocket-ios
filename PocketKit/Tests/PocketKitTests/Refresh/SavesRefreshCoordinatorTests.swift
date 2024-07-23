// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import BackgroundTasks

@testable import Sync
@testable import PocketKit
import SharedPocketKit

class SavesRefreshCoordinatorTests: XCTestCase {
    var notificationCenter: NotificationCenter!
    var taskScheduler: MockBGTaskScheduler!
    var source: MockSource!
    var appSession: AppSession!

    override func setUp() {
        super.setUp()
        notificationCenter = NotificationCenter()
        taskScheduler = MockBGTaskScheduler()
        source = MockSource()
        source.stubRefreshSaves { _ in }
        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.setCurrentSession(SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id"))
        taskScheduler.stubRegisterHandler { _, _, _ in
            return true
        }
        taskScheduler.stubCancel { _ in }
        taskScheduler.stubSubmit { _ in }
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        taskScheduler: BGTaskSchedulerProtocol? = nil,
        source: Source? = nil,
        appSession: AppSession? = nil
    ) -> SavesRefreshCoordinator {
        SavesRefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            taskScheduler: taskScheduler ?? self.taskScheduler,
            appSession: appSession ?? self.appSession,
            source: source ?? self.source
        )
    }

    func test_initialize_registersTheBackgroundTask() {
        taskScheduler.stubRegisterHandler { _, _, _ in return true }

        let coordinator = subject()
        coordinator.initialize()

        let registerCall = taskScheduler.registerHandlerCall(at: 0)
        XCTAssertNotNil(registerCall)
        XCTAssertEqual(registerCall?.identifier, coordinator.taskID)
    }

    // Adding target, because we disable submitting background refreshes in the Sim.
    #if !targetEnvironment(simulator)
    func test_receivingAppDidEnterBackgroundNotification_submitsBGAppRefreshRequest() {
        taskScheduler.stubRegisterHandler { _, _, _ in return true }
        taskScheduler.stubSubmit { _ in }

        let coordinator = subject()
        coordinator.initialize()
        notificationCenter?.post(name: UIScene.didEnterBackgroundNotification, object: nil)

        let submitCall = taskScheduler.submitCall(at: 0)
        XCTAssertNotNil(submitCall)
        XCTAssertTrue(submitCall?.taskRequest is BGProcessingTaskRequest)
        XCTAssertEqual(submitCall?.taskRequest.identifier, coordinator.taskID)
    }
    #endif

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

    func test_receivingAppWillEnterForegroundNotification_refreshesSource() {
        taskScheduler.stubRegisterHandler { _, _, _ in true }
        source.stubRefreshSaves { _ in }

        let coordinator = subject()
        coordinator.initialize()

        notificationCenter?.post(name: UIScene.willEnterForegroundNotification, object: nil)

        XCTAssertNotNil(source.refreshSavesCall(at: 0))
    }

    func test_coordinator_whenNoSession_doesNotRefreshSaves() {
        source.stubRefreshSaves {  _ in
            XCTFail("Should not fetch saves")
        }

        let coordinator = subject(appSession: AppSession(groupID: ""))
        coordinator.initialize()
        XCTAssertNil(source.refreshSavesCall(at: 0))
    }
}
