// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

func pocketPremiumURL(_ url: URL?, user: User) -> URL? {
    guard let url = url else { return nil }
    guard url.host == "getpocket.com", user.status == .premium else { return url }

    let premiumQueryItem = URLQueryItem(name: "premium_user", value: "true")

    if #available(iOS 16, *) {
        return url.appending(queryItems: [premiumQueryItem])
    } else {
        return append(queryItems: [premiumQueryItem], to: url)
    }
}

private func append(queryItems: [URLQueryItem], to url: URL) -> URL {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
    var queryItems = components.queryItems ?? []
    queryItems.append(contentsOf: queryItems)
    components.queryItems = queryItems
    return components.url ?? url
}
