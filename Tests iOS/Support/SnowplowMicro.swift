// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import XCTest

// swiftlint:disable force_try
/**
 Represents the response from /micro/all
 */
struct SnowplowAllEvents: Codable {
    var total: Int
    var good: Int
    var bad: Int
}

/**
 The top level struct that /micro/good provices
 */
struct SnowplowMicroEvent: Codable {
    var schema: String // The type of top level event
    var contexts: [String] // list of included schemas
    var event: SnowplowMicroEventData // the main data to validate

    /**
     Get all the contexts attached to an event
     */
    func getContexts() -> [SnowplowMicroContext] {
        return event.contexts.data
    }

    /**
     Finds the first context of the specified schema type. There is only ever 1 of each type on any given event.
     */
    func getContext(of type: String) -> SnowplowMicroContext? {
        return getContexts().first(where: { $0.schema == type })
    }

    /**
     Pulls the API User out of the event
     */
    func getAPIUserContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/api_user/jsonschema/1-0-1")
    }

    /**
     Pulls the user out of the event
     */
    func getUserContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/user/jsonschema/1-0-1")
    }

    /**
     Pulls the UI out of the event
     */
    func getUIContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/ui/jsonschema/1-0-3")
    }

    /**
     Pulls the content out of the event
     */
    func getContentContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/content/jsonschema/1-0-0")
    }

    /**
     Pulls the slate out of the event
     */
    func getSlateContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/slate/jsonschema/1-0-0")
    }

    /**
     Pulls the slate lineup out of the event
     */
    func getSlateLineupContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/slate_lineup/jsonschema/1-0-0")
    }

    /**
     Pulls the recommendation out of the event
     */
    func getRecommendationContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/recommendation/jsonschema/1-0-0")
    }

    /**
     Pulls the recommendation out of the event
     */
    func getCorpusRecommendationContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/corpus_recommendation/jsonschema/1-0-0")
    }

    /**
     Pulls the report out of the event
     */
    func getReportContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/report/jsonschema/1-0-0")
    }

    /**
     Pulls the screen out of the event
     */
    func getScreenContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.snowplowanalytics.mobile/screen/jsonschema/1-0-0")
    }

    /// Pulls the feature flag out of the event
    func getFeatureFlagContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/feature_flag/jsonschema/1-0-0")
    }
}

struct SnowplowMicroEventData: Codable {
    var unstruct_event: SnowplowMicroUnstructEvent
    var contexts: SnowplowMicroEventContext
}

struct SnowplowMicroEventContext: Codable {
    var schema: String
    var data: [SnowplowMicroContext]
}

struct SnowplowMicroUnstructEvent: Codable {
    var schema: String
    var data: SnowplowMicroContext
}

/**
 The snowplow struct that contains the data we would validate under data dict
 In the future we could use schema value and Codable to serialize these back into the objects we use in Snowplow for easier validation.
 */
struct SnowplowMicroContext: Codable {
    var schema: String
    var data: AnyCodable

    func dataDict() -> [String: Any?] {
        return data.value as! [String: Any?]
    }

    func has(identifier: String) -> Bool {
        return (self.dataDict()["identifier"] as? String) == identifier
    }

    func has(url: String) -> Bool {
        return (self.dataDict()["url"] as? String) == url
    }

    func has(index: Int) -> Bool {
        return (self.dataDict()["index"] as? Int) == index
    }

    func assertHas(url: String) {
        return XCTAssertEqual((self.dataDict()["url"] as? String), url)
    }

    func has(recomendationId: String) -> Bool {
        return (self.dataDict()["recommendation_id"] as? String) == recomendationId
    }

    func has(corpusRecomendationID: String) -> Bool {
        return (self.dataDict()["corpus_recommendation_id"] as? String) == corpusRecomendationID
    }

    func has(slateId: String) -> Bool {
        return (self.dataDict()["slate_id"] as? String) == slateId
    }

    func has(reason: String) -> Bool {
        return (self.dataDict()["reason"] as? String) == reason
    }

    func assertHas(reason: String) {
        return XCTAssertEqual((self.dataDict()["reason"] as? String), reason)
    }

    func assertHas(type: String) {
        return XCTAssertEqual((self.dataDict()["type"] as? String), type)
    }

    func assertHas(componentDetail: String) {
        return XCTAssertEqual((self.dataDict()["component_detail"] as? String), componentDetail)
    }
}

/**
 Class used to interact with Snowplow Micro
 */
class SnowplowMicro {
    private lazy var decoder: JSONDecoder = {
        let aDecoder = JSONDecoder()
        aDecoder.dateDecodingStrategy = .millisecondsSince1970

        return aDecoder
    }()

    var client: any HTTPDataDownloader

    init(client: any HTTPDataDownloader = URLSession.shared) {
        self.client = client
    }

    /**
     Make a request to snowplow micro
     */
    internal func snowplowRequest(path: String, method: String = "GET", shouldWait: Bool = true) async -> Data {
        if shouldWait {
            // For now we wait 1 seconds for snowplow data to be available because the iOS app flushes it to the server.
            _ = await XCTWaiter.fulfillment(of: [XCTestExpectation(description: "Wait 5 seconds for snowplow data to be available.")], timeout: 1.0)
        }
        let data = try! await self.client.httpData(from: URL(string: "http://localhost:9090\(path)")!, method: method)
        return data
    }

    /**
     Resets snowplow micro events and event counter
     */
    func resetSnowplowEvents() async {
        _ = await snowplowRequest(path: "/micro/reset", method: "POST", shouldWait: false)
    }

    /**
     Gets all the event counts from snowplow micro
     */
    func getAllSnowplowEvents() async -> SnowplowAllEvents {
        let data = await snowplowRequest(path: "/micro/all")
        return try! decoder.decode(SnowplowAllEvents.self, from: data)
    }

    /**
     Gets the list of good event data from snowplow micro to validate
     */
    func getGoodSnowplowEvents() async -> [SnowplowMicroEvent] {
        let data = await snowplowRequest(path: "/micro/good")
        return try! decoder.decode([SnowplowMicroEvent].self, from: data)
    }

    /**
     Gets the list of bad events from snowplow micro with the errors on why
     */
    func getBadSnowplowEvents() async -> [[String: Any]] {
        let data = await snowplowRequest(path: "/micro/bad")
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
    }

    /**
     Gets the first event we can find with the given UI identifier
     */
    func getFirstEvent(with uiIdentifier: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier)
        })
    }

    /**
     Gets the first event we can find with the given UI Identifier and url in the Content Context
     */
    func getFirstEvent(with uiIdentifier: String, contentUrl: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext(), let contentContext = $0.getContentContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier) && contentContext.has(url: contentUrl)
        })
    }

    /**
     Gets the first event we can find with the given UI Identifier and recommendation ID in the recommendation context
     */
    func getFirstEvent(with uiIdentifier: String, recommendationId: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext(), let recommendationContext = $0.getRecommendationContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier) && recommendationContext.has(recomendationId: recommendationId)
        })
    }

    /**
     Gets the first event we can find with the given UI Identifier and recommendation ID in the recommendation context
     */
    func getFirstEvent(with uiIdentifier: String, corpusRecommendationID: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext(), let recommendationContext = $0.getCorpusRecommendationContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier) && recommendationContext.has(corpusRecomendationID: corpusRecommendationID)
        })
    }

    /**
     Gets the first event we can find with the given UI Identifier and slate ID in the slate context
     */
    func getFirstEvent(with uiIdentifier: String, slateId: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext(), let slateContext = $0.getSlateContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier) && slateContext.has(slateId: slateId)
        })
    }

    /**
     Gets the first event we can find with the given UI identifier and position index in a list
     */
    func getFirstEvent(with uiIdentifier: String, index: Int) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext() else {
                return false
            }

            return uiContext.has(identifier: uiIdentifier) && uiContext.has(index: index)
        })
    }
}

/**
 Baseline snowplow assertions we should always make
 */
extension SnowplowMicro {
    /**
     Runs a baseline assertion on all the snowplow events to ensure we are in compliance.
     */
    func assertBaselineSnowplowExpectation() async {
        _ = await [assertNoBadEvents(), assertAllEventsHaveUserAndApiUser()]
    }

    /**
     Ensure that Snowplow micro does not have any bad events.
     */
    func assertNoBadEvents() async {
        let badEvents = await self.getAllSnowplowEvents().bad
        XCTAssertEqual(badEvents, 0, "Bad events were found in snowplow micro")
    }

    /**
     Ensure that Snowplow micro does not have any bad events.
     */
    func assertAllEventsHaveUserAndApiUser() async {
        let allGoodEvents: [SnowplowMicroEvent] = await self.getGoodSnowplowEvents()
        allGoodEvents.forEach { event in
            self.assertAPIUser(for: event)
            self.assertUser(for: event)
        }
    }

    /**
     Ensure that API User on the event has the expected default test values
     */
    internal func assertAPIUser(for event: SnowplowMicroEvent) {
        let apiUser = event.getAPIUserContext()
        XCTAssertNotNil(apiUser, "API User not found in analytics event")
        XCTAssertEqual(apiUser!.dataDict()["api_id"] as! Int, 5512)
        XCTAssertEqual(apiUser!.dataDict()["client_version"] as! String, "1")
    }

    /**
     Ensure that the user on the event has the expected default test values
     */
    internal func assertUser(for event: SnowplowMicroEvent) {
        // Screens in the app that are allowed to not have a userId because the user is logged out.
        let noUserIdScreens = ["PocketKit.LoggedOutViewController"]
        let noUserIdEventIds = ["login.accountdelete.banner.exitsurvey.click", "login.accountdelete.exitsurvey", "login.accountdelete.banner"]

        let user = event.getUserContext()

        if let currentScreenContext = event.getScreenContext(),
           let currentScreen = currentScreenContext.dataDict()["viewController"] as? String,
           noUserIdScreens.contains(currentScreen) {
            // If the screen is in in the list of allowed no user screens, lets return.
            XCTAssertNil(user, "User found in analytics event, and not expected")
            return
        }

        if let currentUIContext = event.getUIContext(),
           let identifier = currentUIContext.dataDict()["identifier"] as? String,
           noUserIdEventIds.contains(identifier) {
            // If the screen is in in the list of allowed no user events, lets return.
            XCTAssertNil(user, "User found in \(identifier) event, and not expected")
            return
        }

        if event.getUIContext() == nil && event.getUserContext() == nil {
            // There are cases (account deletion) where Snowplow auto sends events, without a User context. This is ok so we return without asserting.
            return
        }

        XCTAssertNotNil(user, "User not found in analytics event")
        XCTAssertEqual(user!.dataDict()["hashed_user_id"] as! String, "session-user-id")
        XCTAssertEqual(user!.dataDict()["hashed_guid"] as! String, "session-guid")
    }
}

// MARK: Content Helpers

/**
 Content event helpers
 */
extension SnowplowMicro {
    /**
     Helper function to assert that a given Impression event has the expected URL
     */
    func assertContentImpressionHasUrl(event: SnowplowMicroEvent, url: String) {
        let contentContext = event.getContentContext()
        XCTAssertNotNil(contentContext, "Content context missing from event")
        XCTAssertTrue(contentContext!.has(url: url))
    }

    /**
     Helper function to assert that a given recommendation impression has the necessary entities and url associated
     */
    func assertRecommendationImpressionHasNecessaryContexts(event: SnowplowMicroEvent, url: String) {
        assertContentImpressionHasUrl(event: event, url: url)
        XCTAssertNotNil(event.getSlateContext(), "Recommemdation missing slate context")
        XCTAssertNotNil(event.getSlateLineupContext(), "Recommemdation missing slate lineup context")
    }
}
// swiftlint:enable force_try
