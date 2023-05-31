import Sync
import Foundation
import Localization

extension SavedItem: ItemsListItem {
    var id: String? {
        remoteID
    }

    var domain: String? {
        item?.domain
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item?.timeToRead?.intValue
    }

    var displayTitle: String {
        let itemTitle = item?.title?.isEmpty == false ? item?.title : nil
        return itemTitle ?? item?.bestURL.absoluteString ?? url.absoluteString
    }

    var displayDomain: String? {
        item?.domainMetadata?.name ?? item?.domain ?? host
    }

    var displayDetail: String {
        [displayDomain, displayTimeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    var displayTimeToRead: String? {
        timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { Localization.Item.List.min($0) }
    }

    var displayAuthors: String? {
        let authors: [String]? = item?.authors?.compactMap { ($0 as? Author)?.name }
        return authors?.joined(separator: ", ")
    }

    var host: String? {
        bestURL?.host
    }

    var tagNames: [String]? {
        tags?.compactMap { $0 as? Tag }.compactMap { $0.name }.sorted()
    }

    var cursor: String? {
        item?.savedItem?.cursor
    }

    var savedItemURL: URL? {
        url
    }
}

extension DomainMetadata: ItemsListItemDomainMetadata {
}