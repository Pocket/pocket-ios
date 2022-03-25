import XCTest
import Apollo
import Sync
@testable import SaveToPocketKit


class PocketSaveServiceTests: XCTestCase {
    private var client: MockApolloClient!
    private var backgroundActivityPerformer: MockExpiringActivityPerformer!

    func subject(
        client: ApolloClientProtocol? = nil,
        backgroundActivityPerformer: ExpiringActivityPerformer? = nil
    ) -> PocketSaveService {
        PocketSaveService(
            apollo: client ?? self.client,
            backgroundActivityPerformer: backgroundActivityPerformer ?? self.backgroundActivityPerformer
        )
    }

    override func setUp() async throws {
        backgroundActivityPerformer = MockExpiringActivityPerformer()

        client = MockApolloClient()
        client.stubPerform(toReturnFixtureNamed: "save-item", asResultType: SaveItemMutation.self)
    }

    func test_save_beginsBackgroundActivity_andPerformsSaveItemMutationWithCorrectURL() {
        backgroundActivityPerformer.stubPerformExpiringActivity { _, block in
            block(false)
        }

        let service = subject()
        service.save(url: URL(string: "https://getpocket.com")!)

        XCTAssertNotNil(backgroundActivityPerformer.performCall(at:0))

        let performCall: MockApolloClient.PerformCall<SaveItemMutation>? = client.performCall(at: 0)
        XCTAssertEqual(performCall?.mutation.input.url, "https://getpocket.com")
    }
}
