// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// A formatter for collection URLs
/// valid formats are
/// https://getpocket.com/collections/[slug] (unlocalized)
/// https://getpocket.com/[locale]/collections/[slug] (localized)
public struct CollectionUrlFormatter {
    static let scheme = "https"
    static let host = "getpocket.com"
    static let collectionComponent = "collections"
    static let collectionComponentIndex = 1
    static let localizedCollectionComponentIndex = 2
    static let slugComponentIndex = 2
    static let localizedSlugComponentIndex = 3
    static let minPathComponentsCount = 3

    public init() {}

    private static func collectionUrl(_ urlString: String, collectionIndex: Int) -> URL? {
        guard let url = URL(string: urlString), url.host == Self.host,
              url.pathComponents.count >= Self.minPathComponentsCount,
              url.pathComponents[safe: collectionIndex] == Self.collectionComponent else {
            return nil
        }
        return url
    }

    private static func unlocalizedCollectionUrl(_ urlString: String) -> URL? {
        collectionUrl(urlString, collectionIndex: Self.collectionComponentIndex)
    }

    private static func localizedCollectionUrl(_ urlString: String) -> URL? {
        collectionUrl(urlString, collectionIndex: Self.localizedCollectionComponentIndex)
    }

    public static func collectionUrlString(_ slug: String) -> String {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        return components.url!
            .appendingPathComponent(Self.collectionComponent)
            .appendingPathComponent("\(slug)")
            .absoluteString
    }

    public static func isCollectionUrl(_ urlString: String) -> Bool {
        unlocalizedCollectionUrl(urlString) ?? localizedCollectionUrl(urlString) != nil
    }

    /// Extracts the slug from a collection url, if the passed string maps to a valid collection url
    /// - Parameter urlString: the url string
    /// - Returns: the slug or nil
    public static func slug(from urlString: String) -> String? {
        if let url = unlocalizedCollectionUrl(urlString) {
            return url.pathComponents[safe: Self.slugComponentIndex]
        }
        if let url = localizedCollectionUrl(urlString) {
            return url.pathComponents[safe: Self.localizedSlugComponentIndex]
        }
        return nil
    }
}
