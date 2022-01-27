import Foundation


protocol ItemsListItem {
    var title: String? { get }
    var isFavorite: Bool { get }
    var bestURL: URL? { get }
    var topImageURL: URL? { get }
    var domain: String? { get }

    var domainMetadata: ItemsListItemDomainMetadata? { get }
    var timeToRead: Int? { get }
}

protocol ItemsListItemDomainMetadata {
    var name: String? { get }
}
