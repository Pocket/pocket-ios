// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Route {
    var scheme: String { get }
    var path: String { get }
    var source: ReadableSource { get }
    @MainActor var action: (URL, ReadableSource) -> Void { get }
    func matchedUrlString(from url: URL) -> String?
}

extension Route {
    func matchedUrlString(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        return components.url?.absoluteString
    }
}

struct SpotlightRoute: Route {
    let scheme = "spotlight"
    let path = "/itemURL"
    let source: ReadableSource = .spotlight
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    func matchedUrlString(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
    }
}

struct WidgetRoute: Route {
    let scheme = "pocketWidget"
    let path = "/itemURL"
    let source: ReadableSource = .widget
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    func matchedUrlString(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
    }
}

struct SaveToOpenRoute: Route {
    let scheme = "pocketSaveTo"
    let path = "/itemURL"
    let source: ReadableSource = .saveTo
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    func matchedUrlString(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
    }
}

struct CollectionRoute: Route {
    let scheme = "https"
    let path =  "/collections/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }
}

struct SyndicationRoute: Route {
    let scheme = "https"
    let path =  "/explore/item/"
    let source: ReadableSource = .external
    let action: (URL, ReadableSource) -> Void

    init(action: @escaping (URL, ReadableSource) -> Void) {
        self.action = action
    }

    func matchedUrlString(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.path.contains(path) else {
            return nil
        }
        var normalizedComponents = components
        // remove utm-source and other external query items to obtain the item url
        normalizedComponents.queryItems = nil
        return normalizedComponents.url?.absoluteString
    }
}
