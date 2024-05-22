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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        var normalizedComponents = components
        // remove utm_source and other external query items to obtain the item url
        let updatedQueryItems = normalizedComponents.queryItems?.filter {
            $0.name != "utm_source"
        }
        normalizedComponents.queryItems = updatedQueryItems
        return normalizedComponents.url?.absoluteString
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
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == host,
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        return url.absoluteString
    }
}
