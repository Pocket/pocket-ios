@testable import Sync


extension UnmanagedSlate {
    static func build(
        id: String = "slate-1",
        requestID: String = "slate-1-request",
        experimentID: String = "slate-1-experiment",
        name: String = "A slate",
        description: String = "For use in tests",
        recommendations: [UnmanagedSlate.UnmanagedRecommendation] = []
    ) -> UnmanagedSlate {
        UnmanagedSlate(
            id: id,
            requestID: requestID,
            experimentID: experimentID,
            name: name,
            description: description,
            recommendations: recommendations
        )
    }
}

extension UnmanagedSlate.UnmanagedRecommendation {
    static func build(
        id: String? = "recommendation-1",
        item: UnmanagedItem = .build()
    ) -> UnmanagedSlate.UnmanagedRecommendation {
        return UnmanagedSlate.UnmanagedRecommendation(id: id, item: item)
    }
}
