import CoreData
import PocketGraph

extension Tag {
    typealias TagEdge = TagsQuery.Data.User.Tags.Edge
    func update(remote: TagParts) {
        remoteID = remote.id
        name = remote.name
    }
}
