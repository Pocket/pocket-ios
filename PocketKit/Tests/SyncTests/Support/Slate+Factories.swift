@testable import Sync


extension Slate {
    static func build(
        id: String = "slate-1",
        requestID: String = "slate-1-request",
        experimentID: String = "slate-1-experiment",
        name: String = "A slate",
        description: String = "For use in tests",
        recommendations: [Slate.Recommendation] = []
    ) -> Slate {
        Slate(
            id: id,
            requestID: requestID,
            experimentID: experimentID,
            name: name,
            description: description,
            recommendations: recommendations
        )
    }
}

extension Slate.Recommendation {
    static func build(
        id: String? = "recommendation-1",
        item: UnmanagedItem = .build()
    ) -> Slate.Recommendation {
        return Slate.Recommendation(id: id, item: item)
    }
}
