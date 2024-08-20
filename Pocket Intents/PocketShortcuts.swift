// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AppIntents

class PocketShortcuts: AppShortcutsProvider {
    static var shortcutTitleColor = ShortcutTileColor.orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchSavesIntent(),
            phrases: [
                "Find articles about \(\.$criteria) in \(.applicationName)",
                "Search for \(\.$criteria) in \(.applicationName)",
                "Search \(.applicationName) for \(\.$criteria)",
                "Go to \(.applicationName) and search Saves",
                "Go to \(.applicationName) and search for \(\.$criteria)",
                "Find me some cool stuff in \(.applicationName)"
            ],
            shortTitle: "Pocket Saves",
            systemImageName: "bookmark.fill"
        )
    }
}
