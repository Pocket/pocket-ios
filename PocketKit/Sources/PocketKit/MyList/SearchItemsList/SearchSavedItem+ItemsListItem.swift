import Foundation
import PocketGraph
import Sync

extension SearchSavedItem: ItemsListItem {
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

    var bestURL: URL? {
        guard let itemParts = item.asItem else {
            Log.breadcrumb(category: "search", level: .warning, message: "Skipping updating of Item \(remoteItem.remoteID) because \(item) does not have itemParts")
            return nil
        }

        let resolvedURL = itemParts.resolvedUrl.flatMap(URL.init)
        let givenURL = URL(string: itemParts.givenUrl)
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
        bestURL?.host
    }

    var tagNames: [String]? {
        remoteItem.tags?.compactMap { $0.name }
    }
}

extension SavedItemParts.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
