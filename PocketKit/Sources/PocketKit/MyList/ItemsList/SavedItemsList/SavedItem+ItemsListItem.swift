import Sync
import Foundation

extension SavedItem: ItemsListItem {
    var id: String? {
        remoteID
    }

    var domain: String? {
        item?.domain
    }

    var displayTitle: String {
        item?.title ?? item?.bestURL?.absoluteString ?? ""
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item?.timeToRead?.intValue
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
            .flatMap { L10n.Item.List.min($0) }
    }

    var displayAuthors: String? {
        let authors: [String]? = item?.authors?.compactMap { ($0 as? Author)?.name }
        return authors?.joined(separator: ", ")
    }

    var host: String? {
        bestURL?.host
    }

    var tagNames: [String]? {
        tags?.compactMap { $0 as? Tag }.compactMap { $0.name }
    }

    var cursor: String? {
        item?.savedItem?.cursor
    }
}

extension DomainMetadata: ItemsListItemDomainMetadata {
}
