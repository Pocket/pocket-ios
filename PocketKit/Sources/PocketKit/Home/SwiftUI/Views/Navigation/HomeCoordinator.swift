// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import SwiftUI

/// Navigation coordinator for the Home screen
@Observable
final class HomeCoordinator {
    private static let pathKey = "com.mozilla.pocket.home.path"
    private let userDefaults: UserDefaults

    var path: NavigationPath

    init() {
        // TODO: SWIFTUI - for now let's instatiate and force unwrap this here, just to make this type auto consistent.
        self.userDefaults = UserDefaults(suiteName: Keys.shared.groupID)!
        // decode an existing path if it exists
        guard let pathData = userDefaults.object(forKey: Self.pathKey) as? Data,
        let decodedPath = try? JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: pathData) else {
            path = NavigationPath()
            Log.debug("No path found in user defaults, using default")
            return
        }
        path = NavigationPath(decodedPath)
    }

    func savePath() {
        guard let encodablePath = path.codable else { return }

        do {
            let data = try JSONEncoder().encode(encodablePath)
            userDefaults.set(data, forKey: Self.pathKey)
        } catch {
            Log.debug("Failed to save path: \(error)")
        }
    }

    func navigateTo(_ route: any NavigationRoute) {
        path.append(route)
    }
}
