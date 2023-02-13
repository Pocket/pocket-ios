import Foundation
import CoreData
import PocketGraph

extension Recommendation {
    public typealias RemoteRecommendation = SlateParts.Recommendation

    func update(from remote: RemoteRecommendation, in space: Space) {
        remoteID = remote.id
        title = remote.curatedInfo?.title
        excerpt = remote.curatedInfo?.excerpt
        imageURL = remote.curatedInfo?.imageSrc.flatMap(URL.init)

        guard let recommendationItem = try? space.fetchOrCreateItem(byRemoteID: remote.item.remoteID) else {
            //TODO: Log error.
            return
        }
        recommendationItem.update(from: remote.item.fragments.itemSummary)
        item = recommendationItem
    }
}
