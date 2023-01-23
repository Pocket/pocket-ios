import Foundation
import PocketGraph

protocol ItemsListItem {
    var id: String? { get }
    var title: String? { get }
    var isFavorite: Bool { get }
    var bestURL: URL? { get }
    var topImageURL: URL? { get }
    var domain: String? { get }
    var domainMetadata: ItemsListItemDomainMetadata? { get }
    var timeToRead: Int? { get }
    var isPending: Bool { get }
    var host: String? { get }
    var tagNames: [String]? { get }
    var remoteItemParts: SavedItemParts? { get }
}

extension ItemsListItem {
    var remoteItemParts: SavedItemParts? {
        return nil
    }
}

protocol ItemsListItemDomainMetadata {
    var name: String? { get }
}
