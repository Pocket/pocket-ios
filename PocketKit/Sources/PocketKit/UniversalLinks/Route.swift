// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Route {
    var scheme: String { get }
    var path: String { get }
    var source: ReadableSource { get }
    @MainActor var action: (String) -> Void { get }
    func resolvedUrlString(from components: URLComponents) -> String?
}

extension Route {
    func resolvedUrlString(from components: URLComponents) -> String? {
        guard components.scheme == scheme && components.path.contains(path) else {
            return nil
        }
        return components.url?.absoluteString
    }
}

struct WidgetRoute: Route {
    let scheme = "pocketWidget"
    let path = "/itemURL"
    let source: ReadableSource = .widget
    let action: (String) -> Void

    init(action: @escaping (String) -> Void) {
        self.action = action
    }

    func resolvedUrlString(from components: URLComponents) -> String? {
        guard components.scheme == scheme && components.path == path else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == "url" })?.value
    }
}

struct CollectionRoute: Route {
    let scheme = "https"
    let path =  "/collections/"
    let source: ReadableSource = .external
    let action: (String) -> Void

    init(action: @escaping (String) -> Void) {
        self.action = action
    }
}
