// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public enum SearchScope: String, CaseIterable, Codable {
    case saves = "Saves"
    case archive = "Archive"
    case all = "All items"
    // Premium Experiment
    case premiumSearchByTitle = "Title"
    case premiumSearchByTag = "Tag"
    case premiumSearchByContent = "Content"

    public static var defaultScopes: [SearchScope] {
        return [.saves, .archive, .all]
    }

    public static var premiumScopes: [SearchScope] {
        return [.premiumSearchByTitle, .premiumSearchByTag, .premiumSearchByContent]
    }
}
