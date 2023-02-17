import Foundation
import PocketGraph
import Sync

extension SearchSavedItem: ItemsListItem {
    var remoteItemReaderView: PocketGraph.SavedItemReaderView? {
        return remoteItem
    }

    var id: String? {
        item.asItem?.remoteID
    }

    var isFavorite: Bool {
        remoteItem.isFavorite
    }

    var title: String? {
        item.asItem?.title
    }

    var bestURL: URL? {
        guard let itemReaderView = item.asItem else { return nil }
        let resolvedURL = itemReaderView.resolvedUrl.flatMap(URL.init)
        let givenURL = URL(string: itemReaderView.givenUrl)
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

extension SavedItemReaderView.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
