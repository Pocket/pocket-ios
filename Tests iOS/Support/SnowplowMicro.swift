// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct SnowplowAllEvents: Codable {
    var total: Int
    var good: Int
    var bad: Int
}

struct SnowplowMicroEvent: Codable {
    var schema: String // The type of top level event
    var contexts: [String] // list of included schemas
    var event: SnowplowMicroEventData // the main data to validate
}

struct SnowplowMicroEventData: Codable {
    var unstruct_event: SnowplowMicroUnstructEvent
    var contexts: SnowplowMicroEventContext
}

struct SnowplowMicroEventContext : Codable {
    var schema: String
    var data: [SnowplowMicroContext]
}

struct SnowplowMicroUnstructEvent: Codable {
    var schema: String
    var data: SnowplowMicroContext
}

struct SnowplowMicroContext : Codable {
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
      let _ = await snowplowRequest(path: "/micro/reset", method: "POST")
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
            guard let uiContext = getContext(from: $0, of: "iglu:com.pocket/ui/jsonschema/1-0-3") else {
                return false
            }
            return ((uiContext.data.value as! [String: Any])["identifier"] as? String) == uiIdentifier
        })
    }

    internal func getContext(from event: SnowplowMicroEvent, of type: String) -> SnowplowMicroContext? {
        return event.event.contexts.data.first(where: { $0.schema == type })
    }
}
