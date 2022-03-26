import XCTest
import Apollo
import Sync

@testable import SaveToPocketKit
@testable import Sync


class PocketSaveServiceTests: XCTestCase {
    private var client: MockApolloClient!
    private var backgroundActivityPerformer: MockExpiringActivityPerformer!
    private var space: Space!

    override func setUp() async throws {
        backgroundActivityPerformer = MockExpiringActivityPerformer()
        client = MockApolloClient()
        space = Space(container: .testContainer)
    }

    func subject(
        client: ApolloClientProtocol? = nil,
        backgroundActivityPerformer: ExpiringActivityPerformer? = nil,
        space: Space? = nil
    ) -> PocketSaveService {
        PocketSaveService(
            apollo: client ?? self.client,
            backgroundActivityPerformer: backgroundActivityPerformer ?? self.backgroundActivityPerformer,
            space: space ?? self.space
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
        service.save(url: URL(string: "https://getpocket.com")!)

        XCTAssertNotNil(backgroundActivityPerformer.performCall(at:0))

        wait(for: [performCalled], timeout: 1)
        let performCall: MockApolloClient.PerformCall<SaveItemMutation>? = client.performCall(at: 0)
        XCTAssertEqual(performCall?.mutation.input.url, "https://getpocket.com")
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
        service.save(url: url)

        do {
            wait(for: [performMutationWasCalled], timeout: 1)
            let savedItem = try space.fetchSavedItem(byURL: url)
            XCTAssertNotNil(savedItem)
        }

        do {
            wait(for: [performMutationCompleted], timeout: 1)
            let savedItem = try space.fetchSavedItem(byRemoteID: "saved-item-1")
            XCTAssertNotNil(savedItem?.item)
        }
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
        service.save(url: URL(string: "https://getpocket.com")!)

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


}
