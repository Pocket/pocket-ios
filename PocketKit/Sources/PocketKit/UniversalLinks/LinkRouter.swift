// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

struct LinkRouter {
    private var routes: [Route]

    private var fallbackAction: ((URL) -> Void)?

    init(routes: [Route] = []) {
        self.routes = routes
    }

    mutating func addRoute(_ route: Route) {
        routes.append(route)
    }

    mutating func addRoutes(_ newRoutes: [Route]) {
        routes.append(contentsOf: newRoutes)
    }

    mutating func setFallbackAction(_ action: @escaping (URL) -> Void) {
        self.fallbackAction = action
    }

    @MainActor
    func matchRoute(from url: URL) {
        guard let route = routes.first(where: {
            $0.matchedUrlString(from: url) != nil
        })  else {
            fallbackAction?(url)
            return
        }
        guard let urlString = route.matchedUrlString(from: url), let itemUrl = URL(string: urlString) else {
            fallbackAction?(url)
            return
        }
        route.action(itemUrl, route.source)
    }
}
