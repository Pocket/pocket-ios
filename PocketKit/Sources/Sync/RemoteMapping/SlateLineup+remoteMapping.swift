import Foundation
import CoreData
import PocketGraph
import SharedPocketKit

extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup

    func update(from remote: RemoteSlateLineup, in space: Space, context: NSManagedObjectContext) {
        slates = try? NSOrderedSet(array: remote.slates.enumerated().map {
            let slate = try space.fetchSlate(byRemoteID: $0.element.id, context: context) ?? Slate(context: context, remoteID: $0.element.id, expermimentID: $0.element.experimentId, requestID: $0.element.requestId)
            slate.update(from: $0.element.fragments.slateParts, in: space, context: context)
            slate.sortIndex = NSNumber(value: $0.offset + 1)
            return slate
        })
    }
}

extension Slate {
    public typealias RemoteSlate = SlateParts

    func update(from remoteSlate: RemoteSlate, in space: Space, context: NSManagedObjectContext) {
        experimentID = remoteSlate.experimentId
        remoteID = remoteSlate.id
        name = remoteSlate.displayName
        requestID = remoteSlate.requestId
        slateDescription = remoteSlate.description

        var i = 1
        recommendations = NSOrderedSet(array: remoteSlate.recommendations.compactMap { remote in
            // concatenate recommendation ID with slate ID to ensure that a unique recommendation entity exists even if an actual recommendation is
            // present in more than one slate
            let remoteID = remote.id + remoteSlate.id
            let analyticsID = remote.id
            guard let recommendation = try? space.fetchRecommendation(byRemoteID: remoteID, context: context) ?? Recommendation(context: context, remoteID: remoteID, analyticsID: analyticsID) else {
                return nil
            }
            recommendation.update(from: remote, in: space, context: context)
            recommendation.sortIndex = NSNumber(value: i)
            recommendation.slate = self
            recommendation.analyticsID = analyticsID
            i = i + 1
            return recommendation
        })
    }
}

extension Recommendation {
    public typealias RemoteRecommendation = SlateParts.Recommendation

    func update(from remote: RemoteRecommendation, in space: Space, context: NSManagedObjectContext) {
        guard let url = URL(string: remote.item.givenUrl) else {
            // TODO: Daniel work to make id non-null in the API Layer.
            Log.breadcrumb(category: "sync", level: .warning, message: "Skipping updating of Recomendation because \(remote.item.givenUrl) is not valid url")
            return
        }

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
