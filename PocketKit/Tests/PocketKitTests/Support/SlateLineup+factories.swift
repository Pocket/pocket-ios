@testable import Sync


extension SlateLineup {
    @discardableResult
    static func build(
        in space: Space = .testSpace(),
        remoteID: String = "slate-lineup-1",
        requestID: String = "slate-lineup-1-request",
        experimentID: String = "slate-lineup-1-experiment",
        slates: [Slate] = []
    ) -> SlateLineup {
        let lineup: SlateLineup = space.new()
        lineup.remoteID = remoteID
        lineup.requestID = requestID
        lineup.experimentID = experimentID

        slates.forEach {
            lineup.addToSlates($0)
        }

        return lineup
    }
}

extension Slate {
    @discardableResult
    static func build(
        in space: Space = .testSpace(),
        experimentID: String = "slate-1-experiment",
        remoteID: String = "slate-1",
        name: String = "Slate 1",
        requestID: String = "slate-1-request",
        slateDescription: String = "The description of slate 1",
        recommendations: [Recommendation] = []
    ) -> Slate {
        let slate: Slate = space.new()
        slate.experimentID = experimentID
        slate.remoteID = remoteID
        slate.name = name
        slate.requestID = requestID
        slate.slateDescription = slateDescription

        recommendations.forEach {
            slate.addToRecommendations($0)
        }

        return slate
    }
}

extension Recommendation {
    @discardableResult
    static func build(
        in space: Space = .testSpace(),
        remoteID: String = "slate-1-rec-1",
        item: Item? = nil
    ) -> Recommendation {
        let recommendation: Recommendation = space.new()
        recommendation.remoteID = remoteID
        recommendation.item = item
        return recommendation
    }
}
