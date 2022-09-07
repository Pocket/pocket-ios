import CoreData

extension Tag {
    func update(remote: SavedItemParts.Tag) {
        remoteID = remote.id
        name = remote.name
    }
}
