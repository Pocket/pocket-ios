// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import NIO
import ApolloTestSupport
import PocketGraphTestMocks

class CollectionTests: PocketXCTestCase {
    override func setUp() async throws {
        try await super.setUp()

        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForFeatureFlags {
                return .featureFlags(with: "feature-flags")
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }
    }

    @MainActor
    override func tearDown() async throws {
        try server.stop()
        await snowplowMicro.assertBaselineSnowplowExpectation()
        app.terminate()
        try await super.tearDown()
    }

    @MainActor
    func test_tappingCollectionItem_fromSaves_showsNativeCollectionView() async {
        openCollectionFromSaves()

        let screenViewEvent = await snowplowMicro.getFirstEvent(with: "collection.screen")
        XCTAssertNotNil(screenViewEvent)
    }

    @MainActor
    func test_tappingCollectionItem_fromHome_showsNativeCollectionView() async {
        openCollectionFromHome()

        let screenViewEvent = await snowplowMicro.getFirstEvent(with: "collection.screen")
        XCTAssertNotNil(screenViewEvent)
    }

    @MainActor
    func test_tappingSavesButton_fromNavBar_savesCollection() async {
        openCollectionFromHome()
        app.collectionView.savesButton.wait().tap()

        XCTAssertTrue(app.collectionView.archiveButton.exists)

        let saveEvent = await snowplowMicro.getFirstEvent(with: "collection.save")
        XCTAssertNotNil(saveEvent)
    }

    @MainActor
    func test_tappingArchiveAndSaveNavBarButton_forSavedItem_archivesAndSavesCollection() async {
        openCollectionFromSaves()
        app.collectionView.archiveButton.wait().tap()
        app.saves.wait()
        app.saves.selectionSwitcher.archiveButton.tap()

        let collectionItem = app.saves.itemView(at: 0).wait()
        collectionItem.tap()
        app.collectionView.savesButton.wait().tap()
        XCTAssertTrue(app.collectionView.archiveButton.exists)

        async let unsaveEvent = snowplowMicro.getFirstEvent(with: "collection.unsave")
        async let unarchiveEvent = snowplowMicro.getFirstEvent(with: "collection.un-archive")
        let events = await [unsaveEvent, unarchiveEvent]

        events[0]!.getUIContext()!.assertHas(type: "button")
        events[0]!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")

        events[1]!.getUIContext()!.assertHas(type: "button")
        events[1]!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
    }

    func test_tappingOverflowMenu_fromSavedCollection_showsOverflowOptions() {
        openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()

        XCTAssertTrue(app.collectionView.favoriteButton.exists)
        XCTAssertTrue(app.collectionView.addTagsButton.exists)
        XCTAssertTrue(app.collectionView.deleteButton.exists)
        XCTAssertTrue(app.collectionView.shareButton.exists)
    }

    @MainActor
    func test_tappingFavoriteFromOverflowMenu_forSavedCollection_savesCollection() async {
        openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.favoriteButton.wait().tap()

        let favoriteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.favorite")
        XCTAssertNotNil(favoriteEvent)
    }

    @MainActor
    func test_tappingAddTagsFromOverflowMenu_forSavedCollection_showsAddTags() async {
        openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.addTagsButton.wait().tap()

        let addTagEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.addTag")
        XCTAssertNotNil(addTagEvent)
    }

    @MainActor
    func test_tappingDeleteNoFromOverflowMenu_dismissesDeleteConfirmation() async {
        openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.deleteButton.wait().tap()
        app.collectionView.deleteNoButton.wait().tap()
        XCTAssertTrue(app.collectionView.exists)

        let deleteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.delete")
        XCTAssertNotNil(deleteEvent)
    }

    func test_tappingDeleteYesFromOverflowMenu_dismissesAndDeletesCollection() {
        let collectionCell = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.deleteButton.wait().tap()
        app.collectionView.deleteYesButton.wait().tap()
        app.saves.wait(timeout: 5)
        waitForDisappearance(of: collectionCell)
    }

    @MainActor
    func test_tappingShareFromOverflowMenu_forSavedCollection_showsShare() async {
        openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        XCTAssertTrue(app.collectionView.shareButton.exists)
        app.shareButton.wait().tap()
        app.shareSheet.wait()

        let shareEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.share")
        XCTAssertNotNil(shareEvent)
    }

    func test_tappingReportFromOverflowMenu_forUnsavedCollection_showsReport() {
        openCollectionFromHome()
        app.collectionView.overflowButton.wait().tap()
        XCTAssertTrue(app.collectionView.reportButton.exists)
        app.reportButton.wait().tap()
        app.reportView.wait()
    }

    @MainActor
    func test_tappingStory_fromCollection_opensContent() async {
        openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.open")
        XCTAssertNotNil(openEvent)
    }

    @MainActor
    func test_savingAndunsavingStory_fromCollection_opensContent() async {
        openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").savedButton.wait().tap()

        app.collectionView.cell(containing: "Collection Story 1").saveButton.wait().tap()

        async let unsaveEvent = snowplowMicro.getFirstEvent(with: "collection.story.unsave")
        async let saveEvent = snowplowMicro.getFirstEvent(with: "collection.story.save")
        let events = await [unsaveEvent, saveEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
        }
    }

    @MainActor
    func test_sharingStory_fromCollection() async {
        openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").overflowButton.wait().tap()
        app.shareButton.wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.overflow.share")
        XCTAssertNotNil(openEvent)
    }

    @MainActor
    func test_reportingStory_fromCollection() async {
        openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").overflowButton.wait().tap()
        app.reportButton.wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.overflow.report")
        XCTAssertNotNil(openEvent)
    }

    @discardableResult
    private func openCollectionFromSaves() -> ItemRowElement {
        app.launch().tabBar.savesButton.wait().tap()
        let collectionItem = app
            .saves
            .itemView(matching: "Item 2")
            .wait()
        XCTAssertTrue(collectionItem.collectionLabel.exists)
        collectionItem.tap()
        return collectionItem
    }

    private func openCollectionFromHome() {
        server.routes.post("/graphql") { request, _ -> Response in
            let apiRequest = ClientAPIRequest(request)

            if apiRequest.isForFeatureFlags {
                return .featureFlags(with: "feature-flags")
            } else if apiRequest.isForCollection {
                return .collection(fixtureName: "collection-home")
            }

            return .fallbackResponses(apiRequest: apiRequest)
        }

        app.launch().tabBar.homeButton.wait().tap()
        let collectionItem = app
            .homeView
            .recommendationCell("Slate 1, Recommendation 1")
            .wait()
        XCTAssertTrue(collectionItem.collectionLabel.exists)
        collectionItem.tap()
    }
}
