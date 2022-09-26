import Foundation


extension Highlight {
    typealias RemoteHighlight = Annotations.RemoteAnnotations.Highlight

    func update(remote: RemoteHighlight) {
        remoteID = remote.id
        version = Int32(remote.version)
        quote = remote.quote
        patch = remote.patch
        createdAt = TimeInterval(remote._createdAt).flatMap(Date.init(timeIntervalSince1970:))
        updatedAt = TimeInterval(remote._updatedAt).flatMap(Date.init(timeIntervalSince1970:))
    }
}
