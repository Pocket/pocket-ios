import Foundation
@testable import PocketKit

struct MockItemsListItem: ItemsListItem {
    let title: String?
    let isFavorite: Bool
    let bestURL: URL?
    let topImageURL: URL?
    let domain: String?
    let domainMetadata: ItemsListItemDomainMetadata?
    let timeToRead: Int?
    let isPending: Bool
    let host: String?
    let tagNames: [String]?

    static func build(
        title: String? = nil,
        isFavorite: Bool = false,
        bestURL: URL? = nil,
        topImageURL: URL? = nil,
        domain: String? = nil,
        domainMetadata: ItemsListItemDomainMetadata? = nil,
        timeToRead: Int? = nil,
        isPending: Bool = false,
        host: String? = nil,
        tagNames: [String]? = nil
    ) -> MockItemsListItem {
        MockItemsListItem(
            title: title,
            isFavorite: isFavorite,
            bestURL: bestURL,
            topImageURL: topImageURL,
            domain: domain,
            domainMetadata: domainMetadata,
            timeToRead: timeToRead,
            isPending: isPending,
            host: host,
            tagNames: tagNames
        )
    }
}

struct MockItemsListItemDomainMetadata: ItemsListItemDomainMetadata {
    let name: String?
}
