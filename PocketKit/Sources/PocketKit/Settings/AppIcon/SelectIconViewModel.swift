// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import SharedPocketKit
import UIKit

@MainActor
final class SelectIconViewModel: ObservableObject {
    private let tracker: Tracker
    @Published private(set) var selectedAppIcon: PocketAppIcon

    init(tracker: Tracker) {
        self.tracker = tracker
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = PocketAppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }

    func updateAppIcon(to icon: PocketAppIcon) async {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        guard UIApplication.shared.alternateIconName != icon.iconName else {
            // No need to update since we're already using this icon.
            return
        }
        do {
            try await UIApplication.shared.setAlternateIconName(icon.iconName)
        } catch {
            Log.capture(message: "Updating icon to \(String(describing: icon.iconName)) failed - \(error).")
            // in case of error, restore the existing
            selectedAppIcon = previousAppIcon
        }
    }
    // Analytics
    func trackIconSelectorViewed() {
        tracker.track(event: Events.Settings.iconSelectorImpression())
    }

    func trackIconSelected(_ iconName: String) {
        tracker.track(event: Events.Settings.appBadgeToggled(iconName: iconName))
    }
}
