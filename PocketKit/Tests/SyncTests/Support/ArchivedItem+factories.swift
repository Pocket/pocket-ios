import Foundation
@testable import Sync


extension ArchivedItem {
    static func build(remoteID: String = "archived-item-1") -> ArchivedItem {
        ArchivedItem(
            remoteID: remoteID,
            url: URL(string: "http://example.com")!,
            createdAt: Date(),
            deletedAt: nil,
            isArchived: true,
            isFavorite: false,
            item: .build(id: "item-1")
        )
    }
}
