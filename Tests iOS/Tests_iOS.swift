// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sails
import Combine
import NIO

class Tests_iOS: XCTestCase {
    var server: Application!
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        server = Application()
        app = XCUIApplication()
        try server.start()
    }

    override func tearDownWithError() throws {
        try server.stop()
    }

    func test_firstLaunch_and_persistence_and_interaction() throws {
        assertFirstLaunch()
        assertSubsequentLaunch()
        assertItemInteraction()
    }
}

extension Tests_iOS {
    func response(itemTitle: String) -> Response {
        return Response {
            Status.ok
            """
            {
              "data": {
                "__typename": "Query",
                "userByToken": {
                  "__typename": "User",
                  "userItems": {
                    "__typename": "UserItemConnection",
                    "nodes": [
                      {
                        "__typename": "UserItem",
                        "url": "http://localhost:8080/hello.html",
                        "asyncItem": {
                          "__typename": "AsyncItem",
                          "item": {
                            "__typename": "Item",
                            "title": "\(itemTitle)",
                            "givenUrl": "http://localhost:8080/hello.html"
                          }
                        }
                      }
                    ]
                  }
                }
              }
            }
            """
        }
    }
    
    func assertFirstLaunch() {
        assert(app.state == .notRunning)
        
        server.routes.post("/v3/oauth/authorize") { _, _ in
            Response(
                status: .created,
                headers: [("X-Source", "Pocket")],
                content:
                """
                {
                    "access_token":"the-access-token",
                    "username":"test@example.com",
                    "account": {
                        "firstName":"test",
                        "lastName":"user"
                    }
                }
                """
            )
        }

        server.routes.post("/") { _, loop in
            self.response(itemTitle: "Item")
        }
            
        app.launchEnvironment = [
            "POCKET_V3_BASE_URL": "http://localhost:8080",
            "POCKET_CLIENT_API_URL": "http://localhost:8080"
        ]

        app.launchArguments = [
            "clearKeychain",
            "clearCoreData"
        ]
        app.launch()

        app.textFields["email"].tap()
        app.typeText("test@example.com")

        app.secureTextFields["password"].tap()
        app.typeText("super-secret-password")
        app.buttons["Sign in"].tap()

        let list = app.tables["user-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 1))

        let firstCell = app.cells.element(boundBy: 0)

        XCTAssertTrue(firstCell.waitForExistence(timeout: 1))
        XCTAssertTrue(firstCell.label.starts(with: "Item"))
    }
    
    func assertSubsequentLaunch() {
        assert(app.state == .runningForeground)
        
        app.terminate()
        app.launchArguments = []
        
        var promise: EventLoopPromise<Response>?
        server.routes.post("/") { _, loop in
            promise = loop.makePromise()
            return promise!.futureResult
        }

        app.launch()
        let list = app.tables["user-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 1))

        let firstCell = list.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 1.0))

        XCTAssertEqual(list.cells.count, 1)
        XCTAssertTrue(firstCell.label.starts(with: "Item"))

        promise?.succeed(response(itemTitle: "Updated Item"))
        let predicate = NSPredicate(format: "label BEGINSWITH 'Updated Item'")
        let updatedCell = list.cells.element(matching: predicate)
        XCTAssertTrue(updatedCell.waitForExistence(timeout: 1))
        XCTAssertEqual(list.cells.count, 1)
    }
    
    func assertItemInteraction() {
        assert(app.state == .runningForeground)
        
        server.routes.get("hello.html") { _, _ in
            Response {
            Status.ok
            """
            <html>
                <style>
                    .container {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100%
                    }
                    h1 {
                        font-size: 148;
                        font-family: Arial;
                    }
                </style>
                <body>
                    <div class="container">
                        <h1>Hello, world</h1>
                    </div>
                </body>
            </html>
            """
            }
        }

        let list = app.tables["user-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 1))

        let firstCell = list.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 1))

        firstCell.tap()

        let webView = app.webViews.element(boundBy: 0)
        XCTAssertTrue(webView.waitForExistence(timeout: 1))
        XCTAssertTrue(webView.staticTexts["Hello, world"].waitForExistence(timeout: 1))
    }
}
