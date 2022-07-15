import XCTest
import Apollo
import Sync

@testable import Sync


class PocketSaveServiceTests: XCTestCase {
    private var client: MockApolloClient!
    private var backgroundActivityPerformer: MockExpiringActivityPerformer!
    private var space: Space!
    private var osNotificationCenter: OSNotificationCenter!

    override func setUp() async throws {
        backgroundActivityPerformer = MockExpiringActivityPerformer()
        client = MockApolloClient()
        space = .testSpace()
        osNotificationCenter = OSNotificationCenter(notifications: CFNotificationCenterGetDarwinNotifyCenter())
    }

    override func tearDownWithError() throws {
        try space.clear()
        osNotificationCenter.removeAllObservers()
    }

    func subject(
        client: ApolloClientProtocol? = nil,
        backgroundActivityPerformer: ExpiringActivityPerformer? = nil,
        space: Space? = nil,
        osNotifications: OSNotificationCenter? = nil
    ) -> PocketSaveService {
        PocketSaveService(
            apollo: client ?? self.client,
            expiringActivityPerformer: backgroundActivityPerformer ?? self.backgroundActivityPerformer,
            space: space ?? self.space,
            osNotifications: osNotificationCenter ?? self.osNotificationCenter
        )
    }

    func test_save_beginsBackgroundActivity_andPerformsSaveItemMutationWithCorrectURL() {
        backgroundActivityPerformer.stubPerformExpiringActivity { _, block in
            DispatchQueue.global(qos: .background).async {
                block(false)
            }
        }

        let performCalled = expectation(description: "perform called")
        client.stubPerform(toReturnFixtureNamed: "save-item", asResultType: SaveItemMutation.self) {
            performCalled.fulfill()
        }

        let service = subject()
        let result = service.save(url: URL(string: "https://getpocket.com")!)

        XCTAssertEqual(result, .newItem)
        XCTAssertNotNil(backgroundActivityPerformer.performCall(at:0))

        wait(for: [performCalled], timeout: 1)
        let performCall: MockApolloClient.PerformCall<SaveItemMutation>? = client.performCall(at: 0)
        XCTAssertEqual(performCall?.mutation.input.url, "https://getpocket.com")
    }

    func test_save_whenSavedItemExistsWithGivenURL_returnsExistingItemStatus_postsItemUpdatedNotification() throws {
        let url = URL(string: "http://example.com/item-1")!
        let existingSavedItem = try space.seedSavedItem(url: url.absoluteString)
        backgroundActivityPerformer.stubPerformExpiringActivity { _, _ in }

        let savedItemUpdated = expectation(description: "savedItemUpdated")
        osNotificationCenter.add(observer: self, name: .savedItemUpdated) {
            savedItemUpdated.fulfill()
        }

        let service = subject()
        let result = service.save(url: url)

        XCTAssertEqual(result, .existingItem)
        wait(for: [savedItemUpdated], timeout: 1)

        let notifications = try? space.fetchSavedItemUpdatedNotifications()
        XCTAssertEqual(notifications?.isEmpty, false)
        XCTAssertEqual(notifications?[0].savedItem, existingSavedItem)
        XCTAssertNotNil(notifications?[0].savedItem?.createdAt)
    }

    func test_save_createsAnEmptyItemLocally_andUpdatesFromResponse() throws {
        backgroundActivityPerformer.stubPerformExpiringActivity { _, block in
            DispatchQueue.global(qos: .background).async {
                block(false)
            }
        }

        let performMutationWasCalled = expectation(description: "perform mutation was called")
        let performMutationCompleted = expectation(description: "perform mutation completed")
        client.stubPerform { (operation: SaveItemMutation, _, _, handler) in
            performMutationWasCalled.fulfill()

            DispatchQueue.global(qos: .background).async {
                let result = Fixture.load(name: "save-item").asGraphQLResult(from: operation)
                handler?(.success(result))

                performMutationCompleted.fulfill()
            }

            return MockCancellable()
        }

        let url = URL(string: "https://example.com/a-new-item")!
        let service = subject()
        _ = service.save(url: url)

        do {
            wait(for: [performMutationWasCalled], timeout: 1)
            let savedItem = try space.fetchSavedItem(byURL: url)
            XCTAssertNotNil(savedItem)
            XCTAssertFalse(savedItem!.hasChanges)
        }

        do {
            wait(for: [performMutationCompleted], timeout: 1)
            let savedItem = try space.fetchSavedItem(byRemoteID: "saved-item-1")
            XCTAssertNotNil(savedItem?.item)
        }
    }

    func test_save_whenApolloRequestFails_storesUnresolvedSavedItemAndPostsNotification() throws {
        var expiringActivity: ((Bool) -> Void)?
        backgroundActivityPerformer.stubPerformExpiringActivity { _, _expiringActivity in
            expiringActivity = _expiringActivity
        }

        let performMutationCalled = expectation(description: "perform called")
        client.stubPerform(ofMutationType: SaveItemMutation.self, toReturnError: TestError.anError) {
            performMutationCalled.fulfill()
        }

        let url = URL(string: "https://getpocket.com")!
        let service = self.subject()
        _ = service.save(url: url)

        let notificationReceived = expectation(description: "notificationReceived")
        osNotificationCenter.add(observer: self, name: .unresolvedSavedItemCreated) {
            notificationReceived.fulfill()
        }

        DispatchQueue(label: "start task").async {
            expiringActivity?(false)
        }
        wait(for: [performMutationCalled, notificationReceived], timeout: 1)

        let unresolved = try space.fetchUnresolvedSavedItems()
        XCTAssertEqual(unresolved[0].savedItem?.url, url)
        XCTAssertEqual(unresolved[0].hasChanges, false)
    }

    func test_cancellationOfExpiringActivity_cancelsAllOperationsAndReturnsImmediately() {
        var expiringActivity: ((Bool) -> Void)?
        backgroundActivityPerformer.stubPerformExpiringActivity { _, _expiringActivity in
            expiringActivity = _expiringActivity
        }

        let queue = DispatchQueue.global(qos: .background)
        let cancellable = MockCancellable()
        let performMutationCalled = expectation(description: "perform called")
        client.stubPerform { (_: SaveItemMutation, _, _, _) in
            queue.async { performMutationCalled.fulfill() }
            return cancellable
        }

        let service = self.subject()
        _ = service.save(url: URL(string: "https://getpocket.com")!)

        let finishedActivity = expectation(description: "finished the original call to perform an activity")
        queue.async {
            expiringActivity?(false)
            finishedActivity.fulfill()
        }

        wait(for: [performMutationCalled], timeout: 1)

        let finishedCancellingActivity = expectation(description: "finished cancelling the activity")
        queue.async {
            expiringActivity?(true)
            XCTAssertNotNil(cancellable.cancelCall(at: 0))
            finishedCancellingActivity.fulfill()
        }

        wait(for: [finishedActivity, finishedCancellingActivity], timeout: 1)
    }

    func test_cancellationOfExpiringActivity_setsSkeletonItemAsUnresolved_andPostsNotification() throws {
        var expiringActivity: ((Bool) -> Void)?
        backgroundActivityPerformer.stubPerformExpiringActivity { _, _expiringActivity in
            expiringActivity = _expiringActivity
        }

        let performMutationCalled = expectation(description: "perform called")
        client.stubPerform { (_: SaveItemMutation, _, _, _) in
            performMutationCalled.fulfill()
            return MockCancellable()
        }

        let url = URL(string: "https://getpocket.com")!
        let service = self.subject()
        _ = service.save(url: url)

        let notificationReceived = expectation(description: "notificationReceived")
        osNotificationCenter.add(observer: self, name: .unresolvedSavedItemCreated) {
            notificationReceived.fulfill()
        }

        DispatchQueue(label: "start task").async {
            expiringActivity?(false)
        }
        wait(for: [performMutationCalled], timeout: 1)

        DispatchQueue(label: "cancel task").async {
            expiringActivity?(true)
        }
        wait(for: [notificationReceived], timeout: 1)

        let unresolved = try space.fetchUnresolvedSavedItems()
        XCTAssertEqual(unresolved[0].savedItem?.url, url)
        XCTAssertEqual(unresolved[0].hasChanges, false)
    }

    func test_save_sendsANotificationAfterCreatingSkeletonSavedItem_andAfterUpdatingTheItem() {
        backgroundActivityPerformer.stubPerformExpiringActivity { _, block in
            DispatchQueue.global(qos: .background).async { block(false) }
        }

        let performCalled = expectation(description: "performCalled")

        var mutation: SaveItemMutation?
        var mutationCompletion: ((Result<GraphQLResult<SaveItemMutation.Data>, Error>) -> Void)?
        client.stubPerform { (_mutation: SaveItemMutation, _, queue, completion) in
            defer { performCalled.fulfill() }
            mutation = _mutation
            mutationCompletion = completion
            return MockCancellable()
        }

        let savedItemCreated = expectation(description: "savedItemCreated")
        osNotificationCenter.add(observer: self, name: .savedItemCreated) {
            savedItemCreated.fulfill()
        }

        let savedItemUpdated = expectation(description: "savedItemUpdated")
        osNotificationCenter.add(observer: self, name: .savedItemUpdated) {
            savedItemUpdated.fulfill()
        }

        let service = subject()
        _ = service.save(url: URL(string: "https://getpocket.com")!)
        wait(for: [performCalled, savedItemCreated], timeout: 1)

        DispatchQueue.main.async {
            mutationCompletion?(.success(Fixture.load(name: "save-item").asGraphQLResult(from: mutation!)))
        }

        wait(for: [savedItemUpdated], timeout: 1)
        let notifications = try? space.fetchSavedItemUpdatedNotifications()
        XCTAssertEqual(notifications?.isEmpty, false)
    }
}
