import Foundation
@testable import PocketKit

struct MockItemsListItem: ItemsListItem {
    let id: String?
    let title: String?
    let isFavorite: Bool
    let isArchived: Bool
    let bestURL: URL?
    let topImageURL: URL?
    let domain: String?
    let domainMetadata: ItemsListItemDomainMetadata?
    let timeToRead: Int?
    let isPending: Bool
    let host: String?
    let tagNames: [String]?
    let cursor: String?

    static func build(
        id: String? = nil,
        title: String? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        bestURL: URL? = nil,
        topImageURL: URL? = nil,
        domain: String? = nil,
        domainMetadata: ItemsListItemDomainMetadata? = nil,
        timeToRead: Int? = nil,
        isPending: Bool = false,
        host: String? = nil,
        tagNames: [String]? = nil,
        cursor: String? = nil
    ) -> MockItemsListItem {
        MockItemsListItem(
            id: id,
            title: title,
            isFavorite: isFavorite,
            isArchived: isArchived,
            bestURL: bestURL,
            topImageURL: topImageURL,
            domain: domain,
            domainMetadata: domainMetadata,
            timeToRead: timeToRead,
            isPending: isPending,
            host: host,
            tagNames: tagNames,
            cursor: cursor
        )
    }
}

struct MockItemsListItemDomainMetadata: ItemsListItemDomainMetadata {
    let name: String?
}
