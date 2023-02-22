// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import XCTest

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
    
    func getContext(of type: String) -> SnowplowMicroContext? {
        return getContexts().first(where: { $0.schema == type })
    }
    
    func getAPIUserContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/api_user/jsonschema/1-0-1")
    }
    
    func getUserContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/user/jsonschema/1-0-0")
    }
    
    func getUIContext() -> SnowplowMicroContext? {
        return getContext(of: "iglu:com.pocket/ui/jsonschema/1-0-3")
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
 */
struct SnowplowMicroContext: Codable {
    var schema: String
    var data: AnyCodable
    
    func dataDict() -> [String: Any?] {
        return data.value as! [String: Any?]
    }
}

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
    
    internal func snowplowRequest(path: String, method: String = "GET") async -> Data {
        let data = try! await self.client.httpData(from: URL(string: "http://localhost:9090\(path)")!, method: method)
        return data
    }
    
    func resetSnowplowEvents() async {
        _ = await snowplowRequest(path: "/micro/reset", method: "POST")
    }
    
    func getAllSnowplowEvents() async -> SnowplowAllEvents {
        let data = await snowplowRequest(path: "/micro/all")
        return try! decoder.decode(SnowplowAllEvents.self, from: data)
    }
    
    func getGoodSnowplowEvents() async -> [SnowplowMicroEvent] {
        let data = await snowplowRequest(path: "/micro/good")
        return try! decoder.decode([SnowplowMicroEvent].self, from: data)
    }
    
    func getBadSnowplowEvents() async -> [[String: Any]] {
        let data = await snowplowRequest(path: "/micro/bad")
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
    }
    
    func getFirstEvent(with uiIdentifier: String) async -> SnowplowMicroEvent? {
        let events = await getGoodSnowplowEvents()
        return events.first(where: {
            guard let uiContext = $0.getUIContext() else {
                return false
            }
            return ((uiContext.data.value as! [String: Any])["identifier"] as? String) == uiIdentifier
        })
    }
    
}

extension SnowplowMicro {
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
        let allGoodEvents : [SnowplowMicroEvent] = await self.getGoodSnowplowEvents()
        allGoodEvents.forEach { event in
            XCTAssertNotNil(event.getAPIUserContext(), "API User not found in analytics event")
            XCTAssertNotNil(event.getUserContext(), "User not found in analytics event")
        }
    }
}
