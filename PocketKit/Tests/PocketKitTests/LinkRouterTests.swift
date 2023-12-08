// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import PocketKit

class LinkRouterTests: XCTestCase {
    func testWidgetRoute() async {
        // Given
        let widgetRouteExpectation = expectation(description: "Widget route matched")
        let widgetItemUrlString = "pocketWidget:/itemURL?url=https://example.com/this_is_an_article/"
        var router = LinkRouter()
        let widgetRoute = WidgetRoute { url, source in
            XCTAssertEqual(url.absoluteString, "https://example.com/this_is_an_article/")
            XCTAssertEqual(source, .widget)
            widgetRouteExpectation.fulfill()
        }

        let collectionRoute = CollectionRoute { _, _ in
            XCTFail("Collection route should not have been matched")
        }
        let syndicatedRoute = SyndicationRoute { _, _ in
            XCTFail("Syndicated route should not have been matched")
        }
        let fallbackAction: (URL) -> Void = { _ in
            XCTFail("Fallback action should not have been triggered")
        }
        router.setFallbackAction(fallbackAction)
        router.addRoutes([collectionRoute, syndicatedRoute, widgetRoute])
        // When
        await router.matchRoute(from: URL(string: widgetItemUrlString)!)
        // Then
        await fulfillment(of: [widgetRouteExpectation], timeout: 1)
    }

    func testCollectionRoute() async {
        // Given
        let collectionRouteExpectation = expectation(description: "Collection route matched")
        let collectionItemUrlString = "https://getpocket.com/collections/example.com/this_is_a_collection/"
        var router = LinkRouter()
        let collectionRoute = CollectionRoute { url, source in
            XCTAssertEqual(url.absoluteString, collectionItemUrlString)
            XCTAssertEqual(source, .external)
            collectionRouteExpectation.fulfill()
        }

        let syndicatedRoute = SyndicationRoute { _, _ in
            XCTFail("Syndicated route should not have been matched")
        }
        let widgetRoute = WidgetRoute { _, _ in
            XCTFail("Widget route should not have been matched")
        }
        let fallbackAction: (URL) -> Void = { _ in
            XCTFail("Fallback action should not have been triggered")
        }
        router.setFallbackAction(fallbackAction)
        router.addRoutes([collectionRoute, syndicatedRoute, widgetRoute])
        // When
        await router.matchRoute(from: URL(string: collectionItemUrlString)!)
        // Then
        await fulfillment(of: [collectionRouteExpectation], timeout: 1)
    }

    func testSyndicatedRoute() async {
        // Given
        let syndicatedRouteExpectation = expectation(description: "Syndicated route matched")
        let syndicatedItemUrlString = "https://getpocket.com/explore/item/example.com/this_is_a_syndicated_article/"
        var router = LinkRouter()
        let syndicatedRoute = SyndicationRoute { url, source in
            XCTAssertEqual(url.absoluteString, syndicatedItemUrlString)
            XCTAssertEqual(source, .external)
            syndicatedRouteExpectation.fulfill()
        }

        let collectionRoute = CollectionRoute { _, _ in
            XCTFail("Collection route should not have been matched")
        }
        let widgetRoute = WidgetRoute { _, _ in
            XCTFail("Widget route should not have been matched")
        }
        let fallbackAction: (URL) -> Void = { _ in
            XCTFail("Fallback action should not have been triggered")
        }
        router.setFallbackAction(fallbackAction)
        router.addRoutes([collectionRoute, syndicatedRoute, widgetRoute])
        // When
        await router.matchRoute(from: URL(string: syndicatedItemUrlString)!)
        // Then
        await fulfillment(of: [syndicatedRouteExpectation], timeout: 1)
    }

    func testImproperUrlTriggersFallbackAction() async {
        let fallbackExpectation = expectation(description: "Fallback action triggered")
        let nonMatchingUrl = "https://getpocket.com/hellothere/example.com/this_is_unsupported_for_now/"
        var router = LinkRouter()
        let collectionRoute = CollectionRoute { _, _ in
            XCTFail("Collection route should not have been matched")
        }
        let widgetRoute = WidgetRoute { _, _ in
            XCTFail("Widget route should not have been matched")
        }
        let syndicatedRoute = SyndicationRoute { _, _ in
            XCTFail("Syndicated route should not have been matched")
        }
        let fallbackAction: (URL) -> Void = { url in
            XCTAssertEqual(url.absoluteString, nonMatchingUrl)
            fallbackExpectation.fulfill()
        }
        router.setFallbackAction(fallbackAction)
        router.addRoutes([collectionRoute, syndicatedRoute, widgetRoute])
        // When
        await router.matchRoute(from: URL(string: nonMatchingUrl)!)
        // Then
        await fulfillment(of: [fallbackExpectation], timeout: 1)
    }
}
