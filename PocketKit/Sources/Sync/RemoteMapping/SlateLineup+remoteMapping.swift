import Foundation
import CoreData


extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup

    func update(from remote: RemoteSlateLineup, in space: Space) {
        remoteID = remote.id
        requestID = remote.requestId
        experimentID = remote.experimentId

        if let slates = slates {
            removeFromSlates(slates)
        }
        remote.slates.forEach { remote in
            let slate: Slate = space.new()
            slate.update(from: remote.fragments.slateParts, in: space)
            addToSlates(slate)
        }
    }
}

extension Slate {
    public typealias RemoteSlate = SlateParts

    func update(from remote: RemoteSlate, in space: Space) {
        experimentID = remote.experimentId
        remoteID = remote.id
        name = remote.displayName
        requestID = remote.requestId
        slateDescription = remote.description

        recommendations = NSOrderedSet(array: remote.recommendations.compactMap { remote in
            guard let remoteID = remote.id,
                  let recommendation = try? space.fetchOrCreateRecommendation(byRemoteID: remoteID) else {
                return nil
            }
            recommendation.update(from: remote, in: space)
            return recommendation
        })
    }
}

extension Recommendation {
    public typealias RemoteRecommendation = SlateParts.Recommendation

    func update(from remote: RemoteRecommendation, in space: Space) {
        remoteID = remote.id

        let recommendationItem = try? space.fetchOrCreateItem(byRemoteID: remote.item.remoteId)
        recommendationItem?.update(remote: remote.item.fragments.itemParts)
        item = recommendationItem
    }
}
