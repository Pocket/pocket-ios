// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Analytics

class AddSavedItemModel {
    let tracker: Tracker
    private let source: Source

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
    }

    func saveURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
           trackUserDidSaveItem(success: false)
            return false
        }

        source.save(url: url)
        trackUserDidSaveItem(success: true)
        return true
    }

    func trackShowView() {
        tracker.track(event: Events.Saves.userDidOpenAddSavedItem())
    }

    func trackUserDidSaveItem(success: Bool) {
        tracker.track(event: Events.Saves.userDidSaveItem(saveSucceeded: success))
    }

    func trackUserDidDismissView() {
        tracker.track(event: Events.Saves.userDidDismissAddSavedItem())
    }
}
