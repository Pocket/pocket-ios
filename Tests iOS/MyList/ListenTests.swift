// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ListenTests: XCTestCase {
    var server: Sails.Application!
    var app: PocketAppElement!
    var snowplowMicro = SnowplowMicro()

    override func setUp() async throws {
        continueAfterFailure = false

        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)
        await snowplowMicro.resetSnowplowEvents()

        server = Application()

        server.routes.post("/graphql") { request, _ -> Response in
            return .fallbackResponses(apiRequest: ClientAPIRequest(request))
        }

        try server.start()
    }

    @MainActor
    override func tearDown() async throws {
        try server.stop()
        app.terminate()
        await snowplowMicro.assertNoBadEvents()
    }

    func test_listen_shows_whenInFlag() {
        let flagsLoaded = expectation(description: "loaded flags")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForFeatureFlags {
                defer { flagsLoaded.fulfill() }
                return .featureFlags("feature-flags-listen")
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(matching: "Item 1").wait()

        wait(for: [flagsLoaded])

        // do a refresh because the flag prob loaded in the background.
        app.saves.pullToRefresh()

        app.saves.filterButton(for: "Listen").wait().tap()
        app.listenPlay.wait()
    }

    func test_listen_doesNotShow_whenNotInFlag() {
        app.launch().tabBar.savesButton.wait().tap()
        app.saves.itemView(matching: "Item 1").wait()

        waitForDisappearance(of: app.saves.filterButton(for: "Listen"))
    }

    @MainActor
    func test_listen_andNotInPlaylistSupport_removesFilterIfSelected() async {
        let flagsLoaded = expectation(description: "loaded flags")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForFeatureFlags {
                defer { flagsLoaded.fulfill() }
                return .featureFlags("feature-flags-listen")
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch().tabBar.savesButton.wait().tap()
        await fulfillment(of: [flagsLoaded])
        app.saves.itemView(matching: "Item 1").wait()
        app.saves.filterButton(for: "Tagged").wait().tap()
        app.saves.tagsFilterView.wait().allTagCells(matching: "tag 2").wait().tap()
        app.saves.itemView(matching: "Item 2").wait()
        app.saves.filterButton(for: "Listen").wait().tap()
        app.listenPlay.wait()
        // ensure both items are visible and not filtered
        app.listenList.staticTexts["Item 1"].wait()
        app.listenList.staticTexts["Item 2"].wait()
    }

    @MainActor
    func test_listen_andInPlaylistSupport_retainsFilterIfSelected() async {
        let flagsLoaded = expectation(description: "loaded flags")
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForFeatureFlags {
                defer { flagsLoaded.fulfill() }
                return .featureFlags("feature-flags-listen-playlists")
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }
        app.launch().tabBar.savesButton.wait().tap()
        await fulfillment(of: [flagsLoaded])
        app.saves.itemView(matching: "Item 1").wait()
        app.saves.filterButton(for: "Tagged").wait().tap()
        app.saves.tagsFilterView.wait().allTagCells(matching: "tag 2").wait().tap()
        app.saves.itemView(matching: "Item 2").wait()
        app.saves.filterButton(for: "Listen").wait().tap()
        app.listenPlay.wait()
        // ensure only 1 item is visibile and filter is kept
        app.listenList.staticTexts["Item 2"].wait()
        waitForDisappearance(of: app.listenList.staticTexts["Item 1"])
    }
}
