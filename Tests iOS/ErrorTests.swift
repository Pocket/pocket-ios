// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class ErrorTests: PocketXCTestCase {
    override func setUp() async throws {
        try await super.setUp()

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSavesContent {
                return .saves("initial-list-recent-saves")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    @MainActor
    override func tearDown() async throws {
        app.terminate()
        try server.stop()
        await snowplowMicro.assertBaselineSnowplowExpectation()
        try await super.tearDown()
    }

    func test_serverError_banner_for_throttled_user() {
        configureThrottledUser()
                app.launch()
        app.saves.element.staticTexts["Our server is not responding right now. Please bear with us. It should be available within an hour."].wait()
    }

    func test_serverError_banner_for_internal_server_error() {
        configureInternalServerErrorUser()
        app.launch()
        app.saves.element.staticTexts["Something went wrong with your request. The Pocket team has been notified. Please try again later."].wait()
    }

    /// Set user to throttled
    private func configureThrottledUser() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .throttle()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    /// Set user to throttled
    private func configureInternalServerErrorUser() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSavesContent {
                return .internalServerError()
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    func validateBottomMessage() {
        XCTAssertTrue(app.homeView.overscrollText.exists)
    }
}
