// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization

enum SortSection: String, Hashable, CaseIterable {
    case sortBy = "Sort by"
    var localized: String {
        switch self {
        case .sortBy:
            return Localization.SortingOption.sortBy
        }
    }
}

enum SortOption: String, Hashable {
    case newest = "Newest saved"
    case oldest = "Oldest saved"
    case shortestToRead = "Shortest to read"
    case longestToRead = "Longest to read"

    var localized: String {
        switch self {
        case .newest:
            return Localization.SortingOption.newestSaved
        case .oldest:
            return Localization.SortingOption.oldestSaved
        case .shortestToRead:
            return Localization.SortingOption.shortestToRead
        case .longestToRead:
            return Localization.SortingOption.longestToRead
        }
    }
}
