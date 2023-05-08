import XCTest
import CoreData
import Apollo
import Foundation
import SharedPocketKit
import PocketGraph

@testable import Sync

class FetchUserTests: XCTestCase {
    var apollo: MockApolloClient!
    var user: MockUser!

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        user = MockUser()
    }

    func subject(
        user: User? = nil,
        apollo: ApolloClientProtocol? = nil
    ) -> UserService {
        APIUserService(
            apollo: apollo ?? self.apollo,
            user: user ?? self.user
        )
    }

    func test_execute_setsUserInfo() async throws {
        user.stubSetStatus { _ in }
        user.stubSetUserName { _ in }
        user.stubSetDisplayName { _ in }
        user.stubSetEmail { _ in }
        apollo.setupUserSyncResponse()
        let service = subject()
        try await service.fetchUser()
        XCTAssertNotNil(user.setStatusCall(at: 0))
    }
}

extension MockApolloClient {
    func setupUserResponse(fixtureName: String = "user") {
        stubFetch(
            toReturnFixture: .load(name: "user"),
            asResultType: GetUserDataQuery.self
        )
    }

    func setupUserSyncResponse(
        userResponse: String = "user"
    ) {
        setupUserResponse(fixtureName: userResponse)
    }
}
