import Foundation


public struct ArchivedItem: Equatable {
    public let remoteID: String
    public let url: URL?
    public let createdAt: Date
    public let deletedAt: Date?
    public let isArchived: Bool
    public let isFavorite: Bool
    public let item: UnmanagedItem?

    public init(
        remoteID: String,
        url: URL?,
        createdAt: Date,
        deletedAt: Date?,
        isArchived: Bool,
        isFavorite: Bool,
        item: UnmanagedItem?
    ) {
        self.remoteID = remoteID
        self.url = url
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.isArchived = isArchived
        self.isFavorite = isFavorite
        self.item = item
    }
}

extension ArchivedItem {
    init(itemParts: SavedItemParts) {
        self.remoteID = itemParts.remoteId
        self.url = URL(string: itemParts.url)
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(itemParts._createdAt))
        self.deletedAt = itemParts._deletedAt.flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        self.isArchived = itemParts.isArchived
        self.isFavorite = itemParts.isFavorite
        self.item = itemParts.item.fragments.itemParts.flatMap { UnmanagedItem(remote: $0) }
    }
}

extension ArchivedItem {
    public func with(isFavorite: Bool) -> ArchivedItem {
        ArchivedItem(
            remoteID: remoteID,
            url: url,
            createdAt: createdAt,
            deletedAt: deletedAt,
            isArchived: isArchived,
            isFavorite: isFavorite,
            item: item
        )
    }
}
