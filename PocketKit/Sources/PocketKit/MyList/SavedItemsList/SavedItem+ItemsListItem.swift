import Sync
import Foundation


extension SavedItem: ItemsListItem {
    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item.flatMap { Int($0.timeToRead) }
    }

    var domainMetadata: ItemsListItemDomainMetadata? {
        return item?.domainMetadata
    }
}

extension DomainMetadata: ItemsListItemDomainMetadata {

}
