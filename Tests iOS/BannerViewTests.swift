import XCTest
import Sails
import NIO


class BannerViewTests: XCTestCase {
    var server: Application!
    var app: PocketAppElement!

    override func setUpWithError() throws {
        continueAfterFailure = false
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
            } else {
                print(apiRequest)
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
    
    func test_navigatingToHomeTab_withClipboardURLAndAlreadyPresented_showsBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        _ = app.launch().homeView
        app.bannerView.wait()
        
        XCUIDevice.shared.press(.home)
        _ = app.launch().homeView
        app.bannerView.wait()
    }
    
    func test_navigatingToHomeTab_withClipboardURLAndAlreadySaved_showsBannerAndBringSavedItemToTop() {
        let urlString = "https://example.com/item-6"
        UIPasteboard.general.string = urlString
        let home = app.launch().homeView
        let banner = app.bannerView.wait()
        
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                XCTAssertTrue(apiRequest.contains("https:\\/\\/example.com\\/item-6"))
                return Response.saveItem(number: 2)
            }  else {
                fatalError("Unexpected request")
            }

            XCTFail("Received unexpected request")
        }

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)
        
        home.recentSavesView(matching: "Item 6").wait()
        app.tabBar.myListButton.tap()
        app.myListView.itemView(matching: "Item 6").wait()
    }
    
    func test_navigatingToHomeTab_withoutSavedURL_doesNotShowSaveFromClipboardBanner() {
        UIPasteboard.general.string = "get pocket"
        _ = app.launch().homeView
        waitForDisappearance(of: app.bannerView)
    }
    
    func test_navigatingToMyListTab_withClipboardURL_showsBannerAndSavedItem() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.myListButton.wait().tap()
        let banner = app.bannerView.wait()

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)
        
        app.myListView.itemView(matching: "Slate 1, Recommendation 1").wait()
        app.tabBar.homeButton.tap()
        app.homeView.recentSavesView(matching: "Slate 1, Recommendation 1").wait()
    }
    
    func test_navigatingToMyListTab_withClipboardURLAndAlreadyPresented_showsBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.myListButton.wait().tap()
        app.bannerView.wait()
        
        XCUIDevice.shared.press(.home)
        app.launch().tabBar.myListButton.wait().tap()
        app.bannerView.wait()
    }
    
    func test_navigatingToMyListTab_withClipboardURLAndAlreadySaved_showsBannerAndBringSavedItemToTop() {
        let urlString = "https://example.com/item-6"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.myListButton.wait().tap()
        let banner = app.bannerView.wait()
        
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                XCTAssertTrue(apiRequest.contains("https:\\/\\/example.com\\/item-6"))
                return Response.saveItem(number: 2)
            }  else {
                fatalError("Unexpected request")
            }

            XCTFail("Received unexpected request")
        }

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)
        
        app.myListView.itemView(matching: "Item 6").wait()
        app.tabBar.homeButton.tap()
        app.homeView.recentSavesView(matching: "Item 6").wait()
    }
    
    func test_navigatingToMyListTab_withoutSavedURL_doesNotShowSaveFromClipboardBanner() {
        UIPasteboard.general.string = "get pocket"
        app.launch().tabBar.myListButton.wait().tap()
        waitForDisappearance(of: app.bannerView)
    }
    
    func test_navigatingToMyAccount_withClipboardURL_showsBannerAndSavedItem() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.accountButton.wait().tap()
        let banner = app.bannerView.wait()

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)
        
        app.tabBar.myListButton.tap()
        app.myListView.itemView(matching: "Slate 1, Recommendation 1").wait()
        app.tabBar.homeButton.tap()
        app.homeView.recentSavesView(matching: "Slate 1, Recommendation 1").wait()
    }
    
    func test_navigatingToMyAccount_withClipboardURLAndAlreadyPresented_showsBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.accountButton.wait().tap()
        app.bannerView.wait()
        
        XCUIDevice.shared.press(.home)
        app.launch().tabBar.accountButton.wait().tap()
        app.bannerView.wait()
    }
    
    func test_navigatingToMyAccount_withClipboardURLAndAlreadySaved_showsBannerAndBringSavedItemToTop() {
        let urlString = "https://example.com/item-6"
        UIPasteboard.general.string = urlString
        app.launch().tabBar.accountButton.wait().tap()
        let banner = app.bannerView.wait()
        
        server.routes.post("/graphql") { request, loop in
            let apiRequest = ClientAPIRequest(request)
            if apiRequest.isToSaveAnItem {
                XCTAssertTrue(apiRequest.contains("https:\\/\\/example.com\\/item-6"))
                return Response.saveItem(number: 2)
            }  else {
                fatalError("Unexpected request")
            }

            XCTFail("Received unexpected request")
        }

        banner.buttons.firstMatch.tap()
        waitForDisappearance(of: banner)
        
        app.tabBar.myListButton.tap()
        app.myListView.itemView(matching: "Item 6").wait()
        app.tabBar.homeButton.tap()
        app.homeView.recentSavesView(matching: "Item 6").wait()
    }
    
    func test_navigatingToMyAccount_withoutSavedURL_doesNotShowSaveFromClipboardBanner() {
        UIPasteboard.general.string = "get pocket"
        app.launch().tabBar.accountButton.wait().tap()
        waitForDisappearance(of: app.bannerView)
    }
    
    func test_dismissingBanner_withClipboardURL_doesNotShowBanner() {
        let urlString = "https://example.com/item-1"
        UIPasteboard.general.string = urlString
        _ = app.launch().homeView
        let banner = app.bannerView.wait()
        banner.swipeDown()
        waitForDisappearance(of: banner)
    }
}
