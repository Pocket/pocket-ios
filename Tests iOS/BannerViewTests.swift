import XCTest
import Sails
import NIO

class BannerViewTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        let uiApp = XCUIApplication()
        app = PocketAppElement(app: uiApp)

        server = Application()

        server.routes.post("/graphql") { request, _ in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isForSlateLineup {
                return Response.slateLineup()
            } else if apiRequest.isForMyListContent {
                return Response.myList("initial-list-recent-saves")
            } else if apiRequest.isToSaveAnItem {
                return Response.saveItem()
            } else if apiRequest.isForTags {
                return Response.emptyTags()
            } else {
                fatalError("Unexpected request")
            }
        }

        try server.start()
    }

    override func tearDownWithError() throws {
        UIPasteboard.general.string = ""
        try server.stop()
        app.terminate()
    }

    func test_navigatingToHomeTab_withClipboardURL_showsBannerAndSavedItem() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        let home = app.launch().homeView
        let banner = app.bannerView.wait()

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)

        home.recentSavesView(matching: "Slate 1, Recommendation 1").wait()
        app.tabBar.myListButton.tap()
        app.myListView.itemView(matching: "Slate 1, Recommendation 1").wait()
    }

    func test_foregroundingTheApp_withURL_showsSaveFromClipboardBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        _ = app.launch().homeView
        app.bannerView.wait()

        app.tabBar.myListButton.tap()
        app.bannerView.wait()

        XCUIDevice.shared.press(.home)
        _ = app.launch().accountView
        app.bannerView.wait()
    }

    func test_foregroundingTheApp_withAlreadySavedURL_showsSaveFromClipboardBannerAndBringsItemToTop() {
        let urlString = "https://example.com/item-3"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.myListButton.wait().tap()
        app.myListView.itemView(matching: "Item 3").wait()
        app.tabBar.homeButton.tap()
        let banner = app.bannerView.wait()

        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                XCTAssertTrue(apiRequest.contains("https:\\/\\/example.com\\/item-3"))
                return Response.saveItem("save-item-2")
            } else {
                fatalError("Unexpected request")
            }

            XCTFail("Received unexpected request")
        }

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)

        app.homeView.recentSavesView(matching: "Item 3").wait()
    }

    func test_navigatingToHomeTab_withoutSavedURL_doesNotShowSaveFromClipboardBanner() {
        UIPasteboard.general.string = "get pocket"
        _ = app.launch().homeView
        waitForDisappearance(of: app.bannerView)

        app.tabBar.myListButton.tap()
        waitForDisappearance(of: app.bannerView)

        XCUIDevice.shared.press(.home)
        _ = app.launch().accountView
        waitForDisappearance(of: app.bannerView)
    }

    func test_dismissingBanner_withClipboardURL_doesNotShowBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        _ = app.launch().homeView
        let banner = app.bannerView.wait()
        let origin = CGVector(dx: 0.5, dy: 0.5)
        let destination = CGVector(dx: 0.5, dy: 5)

        banner
            .coordinate(withNormalizedOffset: origin)
            .press(forDuration: 0.1, thenDragTo: banner.coordinate(withNormalizedOffset: destination), withVelocity: .fast, thenHoldForDuration: 0)

        waitForDisappearance(of: banner)
    }
}
