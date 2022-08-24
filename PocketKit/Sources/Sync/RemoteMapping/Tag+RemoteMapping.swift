import CoreData


extension Tag {
    func update(remote: SavedItemParts.Tag) {
        name = remote.name
    }
}
