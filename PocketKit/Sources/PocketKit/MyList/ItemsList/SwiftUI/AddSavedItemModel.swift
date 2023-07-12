// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Analytics
import SharedPocketKit

class AddSavedItemItemProvider: ItemProvider {
    private let string: String

    init(string: String) {
        self.string = string
    }

    func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
        return typeIdentifier == "public.plain-text"
    }

    func loadItem(forTypeIdentifier typeIdentifier: String, options: [AnyHashable: Any]?) async throws -> NSSecureCoding {
        return string as NSSecureCoding
    }
}

class AddSavedItemModel {
    let tracker: Tracker
    private let source: Source

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
    }

    func saveURL(_ urlString: String) async -> Bool {
        let itemProvider = AddSavedItemItemProvider(string: urlString)
        let extracted = await URLExtractor.url(from: itemProvider)

        guard let extractedURL = extracted, let url = URL(string: extractedURL), hasValidScheme(url) else {
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

    private func hasValidScheme(_ url: URL) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        if let scheme = urlComponents.scheme {
            return URLExtractor.isValidScheme(scheme)
        }

        return false
    }
}
