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
            let item = (try? space.fetchItem(byRemoteID: remote.item.remoteID)) ??
            Item(
                context: space.context,
                givenURL: URL(string: remote.item.givenUrl)!,
                remoteID: remote.item.remoteID
            )
            item.update(from: remote.item.fragments.itemSummary)
            
            let recommendation = (try? space.fetchOrCreateRecommendation(byRemoteID: remote.id)) ??
            Recommendation(
                context: space.context,
                remoteID: remote.id,
                item: item,
                slate: self
            )
            item.addToRecommendations(recommendation)
            
            recommendation.update(from: remote, in: space)
            return recommendation
        })
    }
}
