import CoreData
import PocketGraph

extension Tag {
    func update(remote: TagParts) {
        remoteID = remote.id
        name = remote.name
    }
}
