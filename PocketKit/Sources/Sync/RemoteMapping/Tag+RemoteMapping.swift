import CoreData

extension Tag {
    func update(remote: TagParts) {
        remoteID = remote.id
        name = remote.name
    }
}
