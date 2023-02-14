import Foundation
import CoreData
import PocketGraph

extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup

    func update(from remote: RemoteSlateLineup, in space: Space) {
        remoteID = remote.id
        requestID = remote.requestId
        experimentID = remote.experimentId

        slates = NSOrderedSet(array: remote.slates.compactMap { remoteSlate in
            guard let slate = try? space.fetchOrCreateSlate(byRemoteID: remote.id) else {
                // TODO: Log error
                return nil
            }
            slate.update(from: remoteSlate.fragments.slateParts, in: space)
            return slate
        })
    }
}
