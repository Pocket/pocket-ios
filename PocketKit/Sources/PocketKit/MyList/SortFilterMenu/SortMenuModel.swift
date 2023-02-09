import Foundation

enum SortSection: String, Hashable, CaseIterable {
    case sortBy = "Sort by"
    var localized: String {
        switch self {
        case .sortBy:
            return L10n.sortBy
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
            return L10n.newestSaved
        case .oldest:
            return L10n.oldestSaved
        case .shortestToRead:
            return L10n.shortestToRead
        case .longestToRead:
            return L10n.longestToRead
        }
    }
}
