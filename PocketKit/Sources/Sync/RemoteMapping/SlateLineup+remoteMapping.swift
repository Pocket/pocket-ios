// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import PocketGraph
import SharedPocketKit

extension SlateLineup {
    public typealias RemoteSlateLineup = GetSlateLineupQuery.Data.GetSlateLineup
    public typealias RemoteHomeLineup = HomeSlateLineupQuery.Data.HomeSlateLineup

    func update(from remote: RemoteHomeLineup, in space: Space, context: NSManagedObjectContext) {
        slates = try? NSOrderedSet(array: remote.slates.enumerated().map {
            let slate = try space.fetchSlate(byRemoteID: $0.element.id, context: context) ?? Slate(context: context, remoteID: $0.element.id, expermimentID: "", requestID: "")
            slate.update(from: $0.element.fragments.corpusSlateParts, in: space, context: context)
            slate.sortIndex = NSNumber(value: $0.offset + 1)
            return slate
        })
    }
}

extension Slate {
    public typealias RemoteSlate = SlateParts
    public typealias RemoteCorpusSlate = CorpusSlateParts

    func update(from remoteSlate: RemoteCorpusSlate, in space: Space, context: NSManagedObjectContext) {
        remoteID = remoteSlate.id
        name = remoteSlate.headline
        slateDescription = remoteSlate.subheadline

        var i = 1
        recommendations = NSOrderedSet(array: remoteSlate.recommendations.compactMap { remote in
            // concatenate recommendation ID with slate ID to ensure that a unique recommendation entity exists even if an actual recommendation is
            // present in more than one slate
            let remoteID = remote.id + remoteSlate.id
            let analyticsID = remote.id
            guard let recommendation = try? space.fetchRecommendation(byRemoteID: remoteID, context: context) ?? CDRecommendation(context: context, remoteID: remoteID, analyticsID: analyticsID) else {
                return
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

extension CDRecommendation {
    public typealias RemoteRecommendation = SlateParts.Recommendation
    public typealias RemoteCorpusRecommendation = CorpusSlateParts.Recommendation

    func update(from remote: RemoteCorpusRecommendation, in space: Space, context: NSManagedObjectContext) {
        title = remote.corpusItem.title
        excerpt = remote.corpusItem.excerpt
        imageURL = URL(string: remote.corpusItem.imageUrl)
        image = CDImage(src: remote.corpusItem.imageUrl, context: context)
        let url = remote.corpusItem.url
        let recommendationItem = (try? space.fetchItem(byURL: url, context: context)) ?? CDItem(context: context, givenURL: url, remoteID: remoteID)
        recommendationItem.update(from: remote.corpusItem, in: space)
        item = recommendationItem
    }
}
