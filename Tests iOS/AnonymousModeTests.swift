// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO

/// End to end tests for Signed Out (aka anonymous) mode
class AnonymousModeTests: PocketXCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)
            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    /// test that the sign in banner appears and calls FxA in anonymous mode
    @MainActor
    func testAnonymousSessionSigninBannerTapped() async {
        let home = app.launch(environment: .anonymousSession).waitForSignedOutHomeToLoad()
        home.sectionHeader("Slate 1").wait()

        let signinButton = home.signinContinueButton.wait()
        signinButton.tap()

        await checkThatFxAWasCalled()
    }

    /// test that tapping a save button presents FxA
    @MainActor
    func testAnonymousSessionRecommendationSaveTapped() async {
        let home = app.launch(environment: .anonymousSession).waitForSignedOutHomeToLoad()
        home.sectionHeader("Slate 1").wait()

        home.signinContinueButton.verify()

        let recommendation1 = home.recommendationCell("Slate 1, Recommendation 1")
        let recommendation2 = home.recommendationCell("Slate 1, Recommendation 2")

        recommendation1.verify()
        recommendation2.verify()

        recommendation1.saveButton.wait().tap()

        await checkThatFxAWasCalled()
    }

    /// test that tapping the "Sign up or sign in" button in the empty view presents FxA
    @MainActor
    func testAnonymousSessionSavesEmptyButtonTapped() async {
        app.launch(environment: .anonymousSession).tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.verify()

        let signinButton =
        listView
            .emptyStateView(for: "saves-empty-state")
            .otherElements
            .buttons["Sign up or sign in"]

        signinButton.verify()
        signinButton.tap()

        await checkThatFxAWasCalled()
    }

    /// test that tapping a filter button presents FxA
    @MainActor
    func testAnonymousSessionSavesEmptyListFilterTapped() async {
        app.launch(environment: .anonymousSession).tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.verify()

        // we test only one button, every other filter button would be the same
        let favoritesButton =
        listView
            .filterButton(for: "Favorites")
        favoritesButton.verify()

        favoritesButton.tap()

        await checkThatFxAWasCalled()
    }

    /// test that tapping the plus button presents FxA
    @MainActor
    func testAnonymousSessionSavesEmptyListAddButtonTapped() async {
        app.launch(environment: .anonymousSession).tabBar.savesButton.wait().tap()

        let listView = app.saves.wait()
        listView.verify()

        let addButton =
        listView
            .addSavedItemButton()
        addButton.verify()

        addButton.tap()

        await checkThatFxAWasCalled()
    }

    /// test that Settings contains the "Sign up or sign in" button and tapping it presents FxA
    @MainActor
    func testAnonymousSessionSettingsSigninButtonTapped() async {
        app.launch(environment: .anonymousSession).tabBar.settingsButton.wait().tap()

        let settingsView = app.settingsView.wait()
        let signinButton = app.settingsView.signinButton

        signinButton.verify()

        signinButton.tap()

        await checkThatFxAWasCalled()
    }

    @MainActor
    private func checkThatFxAWasCalled() async {
        async let authRequest = snowplowMicro.getFirstEvent(with: "signedOut.authentication.requested")

        let events = await [authRequest].compactMap { $0 }
        XCTAssertEqual(events.count, 1)
    }
}
