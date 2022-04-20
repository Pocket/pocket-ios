import Foundation
@testable import Sync
import CoreData

private let space = Space(container: .testContainer)

extension SavedItem {
    static func build(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        isFavorite: Bool = false,
        isArchived: Bool = false,
        cursor: String? = nil,
        item: Item? = .build()
    ) -> SavedItem {
        let savedItem: SavedItem = SavedItem(context: space.context)
        savedItem.cursor = cursor ?? "cursor-\(remoteID)"
        savedItem.remoteID = remoteID
        savedItem.isFavorite = isFavorite
        savedItem.isArchived = isArchived
        savedItem.url = URL(string: url)!
        savedItem.item = item

        return savedItem
    }
}

extension Item {
    static func build(
        remoteID: String = "item-1",
        title: String = "Item 1",
        resolvedURL: URL? = URL(string: "https://getpocket.com")!
    ) -> Item {
        let item = Item(context: space.context)
        item.remoteID = remoteID
        item.title = title
        item.isArticle = true
        item.resolvedURL = resolvedURL

        return item
    }
}
