// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Network
import Sync

struct Router {
    func getItemUrl(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == Self.scheme, components.path == Self.path else {
                  // TODO: log invalid url, or not (it's external, but comes from widget)
            return nil
        }
        return components.queryItems?.first { $0.name == Self.queryItemUrlName }?.value
    }
}

private extension Router {
    static let scheme = "pocket"
    static let host = "home"
    static let path = "/app/openURL"
    static let queryItemUrlName = "url"
}
