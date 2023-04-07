// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

class HomeWebViewTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForSlateLineup {
                return .slateLineup("slates-web-view")
            } else if apiRequest.isForSlateDetail() {
                return .slateLineup("slate-detail-web-view")
            }
            return .fallbackResponses(apiRequest: apiRequest)
        }

        server.routes.get("/hello") { _, _ in
            Response {
                Status.ok
                Fixture.data(name: "hello", ext: "html")
            }
        }

        try server.start()

        app.launch()
    }

    override func tearDownWithError() throws {
        try server.stop()
        app.terminate()
    }

    func test_home_showsWebViewWhenItemIsImage() {
        test_home_showsWebView(from: "Slate 1, Recommendation 1")
    }

    func test_home_showsWebViewWhenItemIsVideo() {
        app.homeView.element.swipeUp()
        test_home_showsWebView(from: "Slate 1, Recommendation 2")
    }

    func test_home_showsWebViewWhenItemIsNotAnArticle() {
        app.homeView.element.swipeUp()
        test_home_showsWebView(from: "Slate 1, Recommendation 3")
    }

    func test_home_showsWebView(from name: String) {
        app.homeView.sectionHeader("Slate 1").wait()
        app.homeView.recommendationCell(name).wait().tap()

        app
            .webReaderView
            .staticText(matching: "Hello, world")
            .wait()
    }
}
