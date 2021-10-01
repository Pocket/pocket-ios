import Foundation
@testable import Sync

extension Space {
    @discardableResult
    func seedItem(
        itemID: String = "the-item-id",
        url: String = "http://example.com/item-1",
        title: String = "Item 1",
        isFavorite: Bool = false
    ) throws -> SavedItem {
        let item = newSavedItem()
        item.itemID = itemID
        item.url = URL(string: url)!
        item.title = title
        item.isFavorite = isFavorite

        try save()
        return item
    }
}
