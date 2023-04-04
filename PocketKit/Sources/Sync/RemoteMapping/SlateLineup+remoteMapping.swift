import Foundation
import CoreData
import PocketGraph

extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup

    func update(from remote: RemoteSlateLineup, in space: Space, context: NSManagedObjectContext) {
        var i = 1
        slates = try? NSOrderedSet(array: remote.slates.map { remoteSlate in
            let slate = try space.fetchSlate(byRemoteID: remoteSlate.id, context: context) ?? Slate(context: context, remoteID: remoteSlate.id, expermimentID: remoteSlate.experimentId, requestID: remoteSlate.requestId)
            slate.update(from: remoteSlate.fragments.slateParts, in: space, context: context)
            slate.sortIndex = NSNumber(value: i)
            i = i + 1
            return slate
        })
    }
}

extension Slate {
    public typealias RemoteSlate = SlateParts

    func update(from remote: RemoteSlate, in space: Space, context: NSManagedObjectContext) {
        experimentID = remote.experimentId
        remoteID = remote.id
        name = remote.displayName
        requestID = remote.requestId
        slateDescription = remote.description

        var i = 1
        recommendations = NSOrderedSet(array: remote.recommendations.compactMap { remote in
            let remoteID = remote.id
            guard let recommendation = try? space.fetchRecommendation(byRemoteID: remoteID, context: context) ?? Recommendation(context: context, remoteID: remoteID) else {
                return nil
            }
            recommendation.update(from: remote, in: space, context: context)
            recommendation.sortIndex = NSNumber(value: i)
            i = i + 1
            return recommendation
        })
    }
}

extension Recommendation {
    public typealias RemoteRecommendation = SlateParts.Recommendation

    func update(from remote: RemoteRecommendation, in space: Space, context: NSManagedObjectContext) {
        let id = remote.id
        guard let url = URL(string: remote.item.givenUrl) else {
            // TODO: Daniel work to make id non-null in the API Layer.
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of Recomendation because \(remote.item.givenUrl) is not valid url")
            return
        }

        remoteID = id
        title = remote.curatedInfo?.title
        excerpt = remote.curatedInfo?.excerpt
        imageURL = remote.curatedInfo?.imageSrc.flatMap(URL.init)
        if let imageSrc = remote.curatedInfo?.imageSrc {
            image = Image(src: imageSrc, context: context)
        }

        let recommendationItem = (try? space.fetchItem(byRemoteID: remote.item.remoteID, context: context)) ?? Item(context: context, givenURL: url, remoteID: remoteID)
        recommendationItem.update(from: remote.item.fragments.itemSummary, with: space)
        item = recommendationItem
    }
}
