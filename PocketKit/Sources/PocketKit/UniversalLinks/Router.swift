// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Network
import Sync

class Router {
    func handle(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == Self.scheme, components.host == Self.host else {
                  // TODO: log invalid url, or not (it's external, but comes from widget)
            return
        }
        // TODO: handle the actual URL here
    }
}

private extension Router {
    static let scheme = "pocket"
    static let host = "home"
}
