import Foundation
import PocketGraph
import Sync

extension SearchSavedItem: ItemsListItem {
    var remoteItemParts: PocketGraph.SavedItemParts? {
        return remoteItem
    }

    var id: String {
        guard let itemParts = item.asItem else {
            // Returning url as an id for pending an id for now.
            return item.asPendingItem!.url
        }
        return itemParts.remoteID
    }

    var isFavorite: Bool {
        remoteItem.isFavorite
    }

    var title: String? {
        item.asItem?.title
    }

    var bestURL: URL {
        guard let itemParts = item.asItem else { return URL(string: item.asPendingItem!.url)! }
        let resolvedURL = itemParts.resolvedUrl.flatMap(URL.init)
        let givenURL = URL(string: itemParts.givenUrl)!
        return resolvedURL ?? givenURL
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
        bestURL.host
    }

    var tagNames: [String]? {
        remoteItem.tags?.compactMap { $0.name }
    }
}

extension SavedItemParts.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
