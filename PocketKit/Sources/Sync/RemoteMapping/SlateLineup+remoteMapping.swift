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
            let slate = (try? space.fetchOrCreateSlate(byRemoteID: remote.id)) ??
                Slate(
                    context: space.context,
                    remoteID: remoteSlate.id,
                    expermimentID: remoteSlate.experimentId,
                    requestID: remoteSlate.requestId,
                    slateLineup: self
                )
            slate.update(from: remoteSlate.fragments.slateParts, in: space)
            return slate
        })
    }
}
