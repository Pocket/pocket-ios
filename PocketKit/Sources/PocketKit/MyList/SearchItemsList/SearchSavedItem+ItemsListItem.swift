import Foundation
import PocketGraph
import Sync
import Localization
import SharedPocketKit

extension SearchSavedItem: ItemsListItem {
    var displayTitle: String {
        title ?? ""
    }

    var displayDetail: String {
        [displayDomain, displayTimeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    var displayDomain: String? {
        item.asItem?.domainMetadata?.name ?? item.asItem?.domain ?? host
    }

    var displayAuthors: String? {
        let authors = item.asItem?.authors?.compactMap { $0?.name }
        return authors?.joined(separator: ", ")
    }

    var displayTimeToRead: String? {
        timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { Localization.Item.List.min($0) }
    }

    var remoteItemParts: PocketGraph.SavedItemParts? {
        return remoteItem
    }

    var id: String? {
        item.asItem?.remoteID
    }

    var isFavorite: Bool {
        remoteItem.isFavorite
    }

    var isArchived: Bool {
        remoteItem.isArchived
    }

    var title: String? {
        item.asItem?.title
    }

    var bestURL: String {
        if let resolvedURL = item.asItem?.resolvedUrl {
            return resolvedURL
        } else if let item = item.asItem {
            return item.givenUrl
        } else if let url = item.asPendingItem?.givenUrl {
            return url
        } else {
            Log.capture(message: "Server returned a search item not as Item or PendingItem")
            return ""
        }
    }

    var topImageURL: URL? {
        guard let topImageUrl = item.asItem?.topImageUrl else { return nil }
        return URL(string: topImageUrl)
    }

    var domain: String? {
        item.asItem?.domain
    }

    var domainMetadata: ItemsListItemDomainMetadata? {
        item.asItem?.domainMetadata
    }

    var timeToRead: Int? {
        item.asItem?.timeToRead
    }

    var isPending: Bool {
        item.asItem == nil
    }

    var host: String? {
        URL(string: bestURL)?.host(percentEncoded: false)
    }

    var tagNames: [String]? {
        remoteItem.tags?.compactMap { $0.name }.sorted()
    }

    var savedItemURL: String {
        remoteItem.url
    }
}

extension SavedItemParts.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
