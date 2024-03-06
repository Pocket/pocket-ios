// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import XCTest
import Sails

class PocketXCTestCase: XCTestCase {
    var server: Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        await snowplowMicro.resetSnowplowEvents()
        server = Application()
        try server.start()
        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }
        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
    }

    @MainActor
    override func tearDown() async throws {
        try server.stop()
        app.terminate()
        await snowplowMicro.assertNoBadEvents()
        try await super.tearDown()
    }
}
