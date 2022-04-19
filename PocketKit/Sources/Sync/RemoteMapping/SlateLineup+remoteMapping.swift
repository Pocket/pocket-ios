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
            slate.update(from: remote, in: space)
            addToSlates(slate)
        }
    }
}

extension Slate {
    public typealias RemoteSlate = SlateLineup.RemoteSlateLineup.Slate

    func update(from remote: RemoteSlate, in space: Space) {
        experimentID = remote.experimentId
        remoteID = remote.id
        name = remote.displayName
        requestID = remote.requestId
        slateDescription = remote.description

        if let recommendations = recommendations {
            removeFromRecommendations(recommendations)
        }
        remote.recommendations.forEach { remote in
            let recommendation: Recommendation = space.new()
            recommendation.update(from: remote, in: space)
            addToRecommendations(recommendation)
        }
    }
}

extension Recommendation {
    public typealias RemoteRecommendation = Slate.RemoteSlate.Recommendation

    func update(from remote: RemoteRecommendation, in space: Space) {
        remoteID = remote.id

        if item != nil {
            item = nil
        }

        let recommendationItem = try? space.fetchOrCreateItem(byRemoteID: remote.item.remoteId)
        recommendationItem?.update(remote: remote.item.fragments.itemParts)
        item = recommendationItem
    }
}
