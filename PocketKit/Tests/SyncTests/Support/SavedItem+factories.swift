import Foundation
@testable import Sync


extension SavedItem {
    @discardableResult
    static func build(
        in space: Space = .testSpace(),
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
