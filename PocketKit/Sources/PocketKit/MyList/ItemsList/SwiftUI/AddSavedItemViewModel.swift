// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Analytics
import SharedPocketKit

/// An ItemProvider that can return a given string as its value, as plain text.
class AddSavedItemItemProvider: ItemProvider {
    private let string: String

    init(string: String) {
        self.string = string
    }

    func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
        // By returning ourself as a plain-text item provider, our URLExtractor can be reused
        // to extract a URL from a given string. In this case, the string is being set at initialization.
        // This means that "Hello, world: https://example.com" can extract "https://example.com",
        // and "some-extension://url?=https://example.com" can also extract "https://example.com". "Normal"
        // urls such as "https://example.com" will be extracted, since the full text _is_ a url.
        return typeIdentifier == "public.plain-text"
    }

    func loadItem(forTypeIdentifier typeIdentifier: String, options: [AnyHashable: Any]?) async throws -> NSSecureCoding {
        // The expectation of URLExtractor is that a public.plain-text ItemProvider will return a String.
        // Since we know this concrete implementation _is_ that of a `public.plain-text` UTI, we can safely
        // ignore the type identifier and options, and return exactly what is needed by the URLExtractor.
        return string as NSSecureCoding
    }
}

class AddSavedItemViewModel {
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

        source.save(url: url.absoluteString)
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
