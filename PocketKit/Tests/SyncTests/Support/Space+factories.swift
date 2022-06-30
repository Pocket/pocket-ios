import Foundation
@testable import Sync

extension Space {
    @discardableResult
    func seedSavedItem(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        archivedAt: Date? = nil,
        cursor: String? = nil,
        item: Item? = nil
    ) throws -> SavedItem {
        var savedItem: SavedItem?

        try context.performAndWait {
            savedItem = new()
            savedItem?.remoteID = remoteID
            savedItem?.isFavorite = isFavorite
            savedItem?.isArchived = isArchived
            savedItem?.createdAt = createdAt
            savedItem?.archivedAt = archivedAt
            savedItem?.url = URL(string: url)!
            savedItem?.cursor = cursor
            savedItem?.item = item ?? new()

            try save()
        }
        
        return savedItem!
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: URL? = URL(string: "https://example.com/items/item-1")
    ) throws -> Item {
        var item: Item?

        context.performAndWait {
            item = new()
            item?.remoteID = remoteID
            item?.title = title
            item?.givenURL = givenURL
        }

        return item!
    }
}
