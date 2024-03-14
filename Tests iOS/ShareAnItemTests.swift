// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails

class ShareAnItemTests: PocketXCTestCase {
    func test_sharingAnItemFromList_presentsShareSheet() {
        app.launch()
        app.tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(matching: "Item 2")
            .shareButton.wait()
            .tap()

        app.shareSheet.wait()
    }

    @MainActor
    func test_sharingAnItemFromReader_presentsShareSheet() async {
        app.launch()
        app.tabBar.savesButton.wait().tap()

        app
            .saves
            .itemView(matching: "Item 1")
            .wait()
            .tap()

        app
            .readerView
            .readerToolbar
            .moreButton.wait()
            .tap()

        app
            .shareButton.wait()
            .tap()

        app.shareSheet.wait()

        await snowplowMicro.assertBaselineSnowplowExpectation()
        let overflowEvent = await snowplowMicro.getFirstEvent(with: "reader.toolbar.share")
        overflowEvent!.getUIContext()!.assertHas(type: "button")
        overflowEvent!.getContentContext()!.assertHas(url: "https://pocket.co/example")
    }

    func test_shareFromHome_sharingARecommendation_sharingFromSlate() {
        let cell = app.launch().homeView.recommendationCell("Slate 1, Recommendation 1").wait()

        cell.overflowButton.wait().tap()
        app.shareButton.wait().tap()

        app.shareSheet.wait()
    }

    func test_shareFromHome_sharingARecommendation_sharingFromSlateDetails() {
        app.launch()
            .homeView
            .sectionHeader("Slate 1")
            .seeAllButton
            .wait().tap()

        let cell = app.slateDetailView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()

        cell.overflowButton.wait().tap()
        app.shareButton.wait().tap()

        app.shareSheet.wait()
    }
}
