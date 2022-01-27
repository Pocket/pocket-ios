import Foundation


public extension SlateLineup {
    typealias Remote = GetSlateLineupQuery.Data.GetSlateLineup
    
    init(remote: Remote) {
        id = remote.id
        requestID = remote.requestId
        experimentID = remote.experimentId
        slates = remote.slates.map { $0.fragments.slateParts }.map(Slate.init)
    }
}

extension Slate {
    typealias Remote = SlateParts

    init(remote: Remote) {
        self.init(
            id: remote.id,
            requestID: remote.requestId,
            experimentID: remote.experimentId,
            name: remote.displayName,
            description: remote.description,
            recommendations: remote.recommendations.map(Slate.Recommendation.init)
        )
    }
}

extension Slate.Recommendation {
    typealias Remote = SlateParts.Recommendation

    init(remote: Remote) {
        self.init(
            id: remote.id,
            item: UnmanagedItem(remote: remote.item.fragments.itemParts)
        )
    }
}
