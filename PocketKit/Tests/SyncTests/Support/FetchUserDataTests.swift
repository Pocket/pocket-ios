// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    override func setUp() {
        super.setUp()
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
