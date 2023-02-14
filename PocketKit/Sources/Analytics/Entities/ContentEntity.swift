// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribingJson

/**
 * A unique piece of content (item) within Pocket, usually represented by a URL.
 * Should be included in all events that relate to content (primarily
 * recommendation card impressions/engagements and item page impressions/engagements).
 */
public struct ContentEntity: Entity {
    public static let schema = "iglu:com.pocket/content/jsonschema/1-0-0"

    /**
     * The full URL of the content.
     */
    let url: URL

    /**
     * The backend identifier for a URL.
     */
    let itemId: String?

    public init(url: URL, itemId: String? = nil) {
        self.url = url
        self.itemId = itemId
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [AnyHashable: Any] = [
            "url": url.absoluteString,
        ]

        if let itemId {
            data["item_id"] = itemId
        }

        return SelfDescribingJson(schema: ContentEntity.schema, andDictionary: data)
    }
}
