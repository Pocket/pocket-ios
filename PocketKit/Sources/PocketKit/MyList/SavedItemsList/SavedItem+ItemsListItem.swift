import Sync
import Foundation

extension SavedItem: ItemsListItem {
    var domain: String? {
        item?.domain
    }

    var title: String? {
        item?.title
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item.flatMap { Int($0.timeToRead) }
    }

    var domainMetadata: ItemsListItemDomainMetadata? {
        return item?.domainMetadata
    }

    var host: String? {
        bestURL?.host
    }

    var tagNames: [String]? {
        tags?.compactMap { $0 as? Tag }.compactMap { $0.name }
    }
}

extension DomainMetadata: ItemsListItemDomainMetadata {
}
