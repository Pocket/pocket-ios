import Foundation
import CoreData
import PocketGraph

extension Slate {
    public typealias RemoteSlate = SlateParts

    func update(from remote: RemoteSlate, in space: Space) {
        experimentID = remote.experimentId
        remoteID = remote.id
        name = remote.displayName
        requestID = remote.requestId
        slateDescription = remote.description

        recommendations = NSOrderedSet(array: remote.recommendations.compactMap { remote in
            guard let recommendation = try? space.fetchOrCreateRecommendation(byRemoteID: remote.id) else {
                return nil
            }
            recommendation.update(from: remote, in: space)
            return recommendation
        })
    }
}
