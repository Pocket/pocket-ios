// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Route {
    var host: String? { get }
    var scheme: String { get }
    var path: String { get }
    var source: ReadableSource { get }
    @MainActor var action: (URL, ReadableSource) -> Void { get }
    func matchedUrlString(from url: URL) -> String?
}

// MARK: Url utilities
private extension URLComponents {
    /// Remove the `utm_source` component from url components, if it exists
    var removedUtmSource: URLComponents {
        var normalizedComponents = self
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents
    }
}

private extension URL {
    /// Builds `URLComponents` matching the passed elements, if they exist
    /// NOTE: the matching criteria for path is contains instead of equality, to account
    /// for localized paths.
    /// - Parameters:
    ///   - host: the host to match
    ///   - scheme: the scheme to match
    ///   - path: the path to match
    /// - Returns: matching URLComponents, or nil.
    func matchedComponents(host: String?, scheme: String?, path: String) -> URLComponents? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        return components
    }
    /// Look for a match between the passed url with the passed host, scheme and path, and extract
    /// the origin url from from the query item named `url`. This is commonly used for special
    /// urls like widgets and Spotlight, but also some standard urls that contain a different origin.
    /// - Parameters:
    ///   - host: the host to match
    ///   - scheme: the scheme to match
    /// - Returns: the absolute string of the matched url found, or nil
    func origin(host: String?, scheme: String?, path: String) -> String? {
        matchedComponents(host: host, scheme: scheme, path: path)?
            .queryItems?
            .first(where: { $0.name == "url" })?
            .value
    }
    /// Look for a match between the passed url with the passed host, scheme and path.
    /// The returned value is the url absolute string minus the `utm_source` query item.
    /// This is done to match the format of stored `Item` urls.
    /// - Parameters:
    ///   - host: the host to match
    ///   - scheme: the scheme to match
    ///   - path: the path to match
    /// - Returns: the absolute string of the matched url, if it's found.
    func matched(host: String?, scheme: String?, path: String) -> String? {
        matchedComponents(host: host, scheme: scheme, path: path)?
            .removedUtmSource
            .url?
            .absoluteString
    }

    /// Look for a match between the passed url with the passed host and scheme.
    /// The returned value is the url absolute string minus the `utm_source` query item.
    /// This is done to match the format of stored `Item` urls.
    /// - Parameters:
    ///   - host: the host to match
    ///   - scheme: the scheme to match
    /// - Returns: the absolute string of the matched url, if it's found.
    func matched(host: String?, scheme: String?) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme else {
            return nil
        }
        return components.removedUtmSource.url?.absoluteString
    }
}

@MainActor
struct SpotlightRoute: Route {
    let host: String? = nil
    let scheme = "spotlight"
    let path = "/itemURL"
    let source: ReadableSource = .spotlight
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.origin(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct WidgetRoute: Route {
    let host: String? = nil
    let scheme = "pocketWidget"
    let path = "/itemURL"
    let source: ReadableSource = .widget
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.origin(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct CollectionRoute: Route {
    let host: String? = "getpocket.com"
    let scheme = "https"
    let path =  "/collections/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct SyndicationRoute: Route {
    let host: String? = "getpocket.com"
    let scheme = "https"
    let path =  "/explore/item/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct GenericItemRoute: Route {
    let host: String? = "getpocket.com"
    let scheme = "https"
    let path =  ""
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme)
    }
}

@MainActor
struct ShortUrlRoute: Route {
    let host: String? = "pocket.co"
    let scheme = "https"
    let path = ""
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme)
    }
}

@MainActor
struct PocketShareRoute: Route {
    let host: String? = "pocket.co"
    let scheme = "https"
    let path = "/share/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct PocketReadRoute: Route {
    let host: String? = "getpocket.com"
    let scheme = "https"
    let path = "/read/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct BrazeIconSwitcherRoute: Route {
    let host: String? = "pocket.co"
    let scheme = "https"
    let path = "/braze/iconSwitcher"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct ListenRoute: Route {
    let host: String? = "getpocket.com"
    let scheme: String = "https"
    let path: String = "/listen"
    let source: ReadableSource = .external
    var action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.origin(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct HomeRoute: Route {
    let host: String? = "getpocket.com"
    let scheme: String = "https"
    let path: String = "/home"
    let source: ReadableSource = .external
    var action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct SavesRoute: Route {
    let host: String? = "getpocket.com"
    let scheme: String = "https"
    let path: String = "/saves"
    let source: ReadableSource = .external
    var action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct SettingsRoute: Route {
    let host: String? = "getpocket.com"
    let scheme: String = "https"
    let path: String = "/settings"
    let source: ReadableSource = .external
    var action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}

@MainActor
struct ManagePremiumRoute: Route {
    let host: String? = "getpocket.com"
    let scheme: String = "https"
    let path: String = "/premium/manage"
    let source: ReadableSource = .external
    var action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    nonisolated func matchedUrlString(from url: URL) -> String? {
        url.matched(host: host, scheme: scheme, path: path)
    }
}
