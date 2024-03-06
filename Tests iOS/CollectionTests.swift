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
        _ = openCollectionFromSaves()

        let screenViewEvent = await snowplowMicro.getFirstEvent(with: "collection.screen")
        screenViewEvent!.getUIContext()!.assertHas(type: "screen")
    }

    @MainActor
    func test_tappingCollectionItem_fromHome_showsNativeCollectionView() async {
        openCollectionFromHome()

        let screenViewEvent = await snowplowMicro.getFirstEvent(with: "collection.screen")
        screenViewEvent!.getUIContext()!.assertHas(type: "screen")
    }

    @MainActor
    func test_tappingSavesButton_fromNavBar_savesCollection() async {
        openCollectionFromHome()
        app.collectionView.savesButton.wait().tap()

        XCTAssertTrue(app.collectionView.archiveButton.exists)

        let saveEvent = await snowplowMicro.getFirstEvent(with: "collection.save")
        saveEvent!.getUIContext()!.assertHas(type: "button")
        saveEvent!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/slate-1-rec-1")
    }

    @MainActor
    func test_tappingArchiveAndSaveNavBarButton_forSavedItem_archivesAndSavesCollection() async {
        _ = openCollectionFromSaves()
        app.collectionView.archiveButton.wait().tap()
        app.saves.wait()
        app.saves.selectionSwitcher.archiveButton.tap()

        let collectionItem = app.saves.itemView(at: 0).wait()
        collectionItem.tap()
        app.collectionView.savesButton.wait().tap()
        XCTAssertTrue(app.collectionView.archiveButton.exists)

        async let unsaveEvent = await snowplowMicro.getFirstEvent(with: "collection.unsave")
        async let unarchiveEvent = await snowplowMicro.getFirstEvent(with: "collection.un-archive")
        let events = await [unsaveEvent, unarchiveEvent]

        events[0]!.getUIContext()!.assertHas(type: "button")
        events[0]!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")

        events[1]!.getUIContext()!.assertHas(type: "button")
        events[1]!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
    }

    @MainActor
    func test_tappingOverflowMenu_fromSavedCollection_showsOverflowOptions() async {
        _ = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()

        XCTAssertTrue(app.collectionView.favoriteButton.exists)
        XCTAssertTrue(app.collectionView.addTagsButton.exists)
        XCTAssertTrue(app.collectionView.deleteButton.exists)
        XCTAssertTrue(app.collectionView.shareButton.exists)

        let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        overflowEvent!.getUIContext()!.assertHas(type: "button")
        overflowEvent!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
    }

    @MainActor
    func test_tappingFavoriteAndUnfavoriteFromOverflowMenu_forSavedCollection_showsShare() async {
        _ = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.favoriteButton.wait().tap()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.unfavoriteButton.wait().tap()

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let favoriteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.favorite")
        async let unfavoriteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.unfavorite")
        let events = await [overflowEvent, favoriteEvent, unfavoriteEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
        }
    }

    @MainActor
    func test_tappingAddTagsFromOverflowMenu_forSavedCollection_showsShare() async {
        _ = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.addTagsButton.wait().tap()

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let addTagEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.addTag")

        let events = await [overflowEvent, addTagEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
        }
    }

    @MainActor
    func test_tappingDeleteNoFromOverflowMenu_dismissesDeleteConfirmation() async {
        _ = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.deleteButton.wait().tap()
        app.collectionView.deleteNoButton.wait().tap()
        XCTAssertTrue(app.collectionView.exists)

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let deleteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.delete")

        let events = await [overflowEvent, deleteEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
        }
    }

    @MainActor
    func test_tappingDeleteYesFromOverflowMenu_dismissesAndDeletesCollection() async {
        let collectionCell = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        app.collectionView.deleteButton.wait().tap()
        app.collectionView.deleteYesButton.wait().tap()
        app.saves.wait()
        waitForDisappearance(of: collectionCell)

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let deleteEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.delete")

        let events = await [overflowEvent, deleteEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
        }
    }

    @MainActor
    func test_tappingShareFromOverflowMenu_forSavedCollection_showsShare() async {
        _ = openCollectionFromSaves()
        app.collectionView.overflowButton.wait().tap()
        XCTAssertTrue(app.collectionView.shareButton.exists)
        app.shareButton.wait().tap()
        app.shareSheet.wait()

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let shareEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.share")
        let events = await [overflowEvent, shareEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/item-2")
        }
    }

    @MainActor
    func test_tappingShareFromOverflowMenu_forUnsavedCollection_showsShare() async {
        openCollectionFromHome()
        app.collectionView.overflowButton.wait().tap()
        XCTAssertTrue(app.collectionView.shareButton.exists)
        app.shareButton.wait().tap()
        app.shareSheet.wait()

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let shareEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.share")
        let events = await [overflowEvent, shareEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/slate-1-rec-1")
        }
    }

    @MainActor
    func test_tappingReportFromOverflowMenu_forUnsavedCollection_showsReport() async {
        openCollectionFromHome()
        app.collectionView.overflowButton.wait().tap()
        XCTAssertTrue(app.collectionView.reportButton.exists)
        app.reportButton.wait().tap()
        app.reportView.wait()

        async let overflowEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow")
        async let reportEvent = await snowplowMicro.getFirstEvent(with: "collection.overflow.report")
        let events = await [overflowEvent, reportEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "https://getpocket.com/collections/slate-1-rec-1")
        }
    }

    @MainActor
    func test_tappingStory_fromCollection_opensContent() async {
        _ = openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.open")
        openEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_savingAndunsavingStory_fromCollection_opensContent() async {
        _ = openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").savedButton.wait().tap()

        app.collectionView.cell(containing: "Collection Story 1").saveButton.wait().tap()

        async let unsaveEvent = await snowplowMicro.getFirstEvent(with: "collection.story.unsave")
        async let saveEvent = await snowplowMicro.getFirstEvent(with: "collection.story.save")
        let events = await [unsaveEvent, saveEvent]

        events.forEach {
            $0!.getUIContext()!.assertHas(type: "button")
            $0!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
        }
    }

    @MainActor
    func test_sharingStory_fromCollection() async {
        _ = openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").overflowButton.wait().tap()
        app.shareButton.wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.overflow.share")
        openEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

    @MainActor
    func test_reportingStory_fromCollection() async {
        _ = openCollectionFromSaves()
        app.collectionView.cell(containing: "Collection Story 1").overflowButton.wait().tap()
        app.reportButton.wait().tap()

        let openEvent = await snowplowMicro.getFirstEvent(with: "collection.story.overflow.report")
        openEvent!.getContentContext()!.assertHas(url: "http://localhost:8080/hello")
    }

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
