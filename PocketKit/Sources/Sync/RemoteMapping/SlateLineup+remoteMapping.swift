import Foundation
import CoreData
import PocketGraph

extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup

    func update(from remote: RemoteSlateLineup, in space: Space) {
        remoteID = remote.id
        requestID = remote.requestId
        experimentID = remote.experimentId

        slates = try? NSOrderedSet(array: remote.slates.map { remoteSlate in
            let slate = try space.fetchSlate(byRemoteID: remoteSlate.id) ?? Slate(context: space.context, remoteID: remoteSlate.id, expermimentID: remoteSlate.experimentId, requestID: remoteSlate.requestId)
            slate.update(from: remoteSlate.fragments.slateParts, in: space)

            return slate
        })
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
                  let recommendation = try? space.fetchRecommendation(byRemoteID: remoteID) ?? Recommendation(context: space.context, remoteID: remoteID) else {
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
        guard let id = remote.id, let url = URL(string: remote.item.givenUrl) else {
            //TODO: Daniel log, also daniel work to make this non-null in the API.
            return
        }
        
        remoteID = id
        title = remote.curatedInfo?.title
        excerpt = remote.curatedInfo?.excerpt
        imageURL = remote.curatedInfo?.imageSrc.flatMap(URL.init)

        let recommendationItem = (try? space.fetchItem(byRemoteID: remote.item.remoteID)) ?? Item(context: space.context, givenURL: url, remoteID: remoteID)
        recommendationItem.update(from: remote.item.fragments.itemSummary)
        item = recommendationItem
    }
}
