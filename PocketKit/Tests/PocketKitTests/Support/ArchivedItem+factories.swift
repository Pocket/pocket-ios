import Foundation
@testable import Sync


extension ArchivedItem {
    static func build(
        remoteID: String = "archived-item-1",
        isFavorite: Bool = false
    ) -> ArchivedItem {
        ArchivedItem(
            remoteID: remoteID,
            url: URL(string: "http://example.com")!,
            createdAt: Date(),
            deletedAt: nil,
            isArchived: true,
            isFavorite: isFavorite,
            item: .build(id: "item-1")
        )
    }
}
