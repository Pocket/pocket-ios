import Foundation
import PocketGraph
import Sync

extension SearchSavedItemParts: ItemsListItem {
    var id: String? {
        item.asItem?.remoteID
    }

    var title: String? {
        item.asItem?.title
    }

    var bestURL: URL? {
        guard let itemParts = item.asItem else { return nil }
        let resolvedURL = itemParts.resolvedUrl.flatMap(URL.init)
        let givenURL = URL(string: itemParts.givenUrl)
        return resolvedURL ?? givenURL
    }

    var topImageURL: URL? {
        guard let topImage = item.asItem?.topImage else { return nil }
        return URL(string: topImage.url)
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
        self.tags?.compactMap { $0.name }
    }
}

extension SearchSavedItemParts.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
