import Foundation

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
}

protocol ItemsListItemDomainMetadata {
    var name: String? { get }
}
