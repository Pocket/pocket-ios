// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

struct LinkRouter {
    private var routes: [Route]

    init(routes: [Route] = []) {
        self.routes = routes
    }

    mutating func addRoute(route: Route) {
        routes.append(route)
    }
    @MainActor
    func matchRoute(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            fallbackToSafari(url: url)
            return
        }
        routes.forEach { route in
            if let destinationUrl = route.resolvedUrlString(from: components) {
                route.action(destinationUrl)
                return
            }
        }
    }

    private func fallbackToSafari(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        fallbackToSafari(url: url)
    }

    private func fallbackToSafari(url: URL) {
        UIApplication.shared.open(url)
    }
}
