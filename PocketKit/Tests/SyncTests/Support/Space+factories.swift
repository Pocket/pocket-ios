import Foundation
@testable import Sync

extension Space {
    @discardableResult
    func seedSavedItem(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        title: String = "Item 1",
        isFavorite: Bool = false
    ) throws -> SavedItem {
        let item: SavedItem = new()
        item.remoteID = remoteID
        item.isFavorite = isFavorite
        item.url = URL(string: url)!

        item.item = new()
        item.item?.title = title

        try save()
        return item
    }
}
