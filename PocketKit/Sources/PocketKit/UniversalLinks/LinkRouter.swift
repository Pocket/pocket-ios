// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

struct LinkRouter {
    private var routes: [Route]

    init(routes: [Route] = []) {
        self.routes = routes
    }

    mutating func addRoute(_ route: Route) {
        routes.append(route)
    }

    mutating func addRoutes(_ newRoutes: [Route]) {
        routes.append(contentsOf: newRoutes)
    }

    @MainActor
    func matchRoute(from url: URL) {
        guard let route = routes.first(where: {
            $0.matchedUrlString(from: url) != nil
        })  else {
            fallbackToSafari(url: url)
            return
        }
        // safe to force-unwrap since we already found the non-nil matching url
        route.action(route.matchedUrlString(from: url)!, route.source)
    }

    private func fallbackToSafari(url: URL) {
        UIApplication.shared.open(url)
    }
}
