import Sync
import Foundation


extension ArchivedItem: ItemsListItem {
    var title: String? {
        item?.title
    }

    var bestURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var domain: String? {
        item?.domain
    }

    var domainMetadata: ItemsListItemDomainMetadata? {
        item?.domainMetadata
    }

    var timeToRead: Int? {
        item?.timeToRead
    }
}

extension UnmanagedItem.DomainMetadata: ItemsListItemDomainMetadata {

}
