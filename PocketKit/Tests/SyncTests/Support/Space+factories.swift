import Foundation
@testable import Sync

extension Space {
    @discardableResult
    func seedSavedItem(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        isFavorite: Bool = false,
        item: Item? = nil
    ) throws -> SavedItem {
        let savedItem: SavedItem = new()
        savedItem.remoteID = remoteID
        savedItem.isFavorite = isFavorite
        savedItem.url = URL(string: url)!

        savedItem.item = item ?? new()

        try context.performAndWait {
            try save()
        }
        
        return savedItem
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1"
    ) throws -> Item {
        let item: Item = new()
        item.remoteID = remoteID
        item.title = title

        return item
    }
}
