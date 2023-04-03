import Foundation
import Localization

enum SortSection: String, Hashable, CaseIterable {
    case sortBy = "Sort by"
    var localized: String {
        switch self {
        case .sortBy:
            return Localization.sortBy
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
            return Localization.newestSaved
        case .oldest:
            return Localization.oldestSaved
        case .shortestToRead:
            return Localization.shortestToRead
        case .longestToRead:
            return Localization.longestToRead
        }
    }
}
