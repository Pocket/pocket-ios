// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AppIntents
import Localization

class PocketShortcuts: AppShortcutsProvider {
    static var shortcutTitleColor = ShortcutTileColor.orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchSavesIntent(),
            phrases: [
                "Show me some cool stuff in \(.applicationName)",
                "Search \(.applicationName)"
            ],
            shortTitle: "intents.searchSaves.title",
            systemImageName: "bookmark.fill"
        )
    }
}
