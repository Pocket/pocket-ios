// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

func pocketPremiumURL(_ url: URL?, user: User) -> URL? {
    guard let url = url else { return nil }
    guard url.host == "getpocket.com", user.status == .premium else { return url }

    let premiumQueryItem = URLQueryItem(name: "premium_user", value: "true")
    return url.appending(queryItems: [premiumQueryItem])
}

func pocketPremiumURL(_ url: String, user: User) -> String? {
    guard let url = URL(string: url) else { return nil }
    guard url.host == "getpocket.com", user.status == .premium else { return url.absoluteString }

    let premiumQueryItem = URLQueryItem(name: "premium_user", value: "true")
    return url.appending(queryItems: [premiumQueryItem]).absoluteString
}

func pocketShareURL(_ url: URL?, source: String) -> URL? {
    guard let url = url else { return nil }

    let sourceQueryItem = URLQueryItem(name: "utm_source", value: source)
    return append(queryItems: [sourceQueryItem], to: url)
}

func pocketShareURL(_ url: String, source: String) -> String? {
    guard let url = URL(string: url) else { return nil }

    let sourceQueryItem = URLQueryItem(name: "utm_source", value: source)
    return append(queryItems: [sourceQueryItem], to: url).absoluteString
}

private func append(queryItems: [URLQueryItem], to url: URL) -> URL {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }

    var updatedQueryItems = components.queryItems ?? []

    queryItems.forEach { item in
        if let index = updatedQueryItems.firstIndex(where: { $0.name == item.name }) {
            updatedQueryItems[index] = item
        } else {
            updatedQueryItems.append(item)
        }
    }

    components.queryItems = updatedQueryItems
    return components.url ?? url
}
