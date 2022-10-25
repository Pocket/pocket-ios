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
            let slate = try space.fetchSlate(byRemoteID: remoteSlate.id) ?? space.new()
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
        title = remote.curatedInfo?.title
        excerpt = remote.curatedInfo?.excerpt
        imageURL = remote.curatedInfo?.imageSrc.flatMap(URL.init)

        let recommendationItem = try? space.fetchOrCreateItem(byRemoteID: remote.item.remoteID)
        recommendationItem?.update(from: remote.item.fragments.itemSummary)
        item = recommendationItem
    }
}
