import Foundation
import PocketGraph

protocol ItemsListItem {
    var id: String? { get }
    var displayTitle: String { get }
    var displayDetail: String { get }
    var isFavorite: Bool { get }
    var isArchived: Bool { get }
    var bestURL: URL? { get }
    var topImageURL: URL? { get }
    var displayDomain: String? { get }
    var displayAuthors: String? { get }
    var displayTimeToRead: String? { get }
    var timeToRead: Int? { get }
    var isPending: Bool { get }
    var host: String? { get }
    var tagNames: [String]? { get }
    var remoteItemParts: SavedItemParts? { get }
    var cursor: String? { get }
}

extension ItemsListItem {
    var remoteItemParts: SavedItemParts? {
        return nil
    }
}

protocol ItemsListItemDomainMetadata {
    var name: String? { get }
}
