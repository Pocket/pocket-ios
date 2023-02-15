import Sync
import Foundation

extension SavedItem: ItemsListItem {
    var id: String? {
        item?.remoteID
    }

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
        item?.timeToRead?.intValue
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
