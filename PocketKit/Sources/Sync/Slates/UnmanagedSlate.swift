import Foundation


public struct UnmanagedSlate: Identifiable, Equatable, Hashable {
    public let id: String
    public let requestID: String
    public let experimentID: String
    public let name: String?
    public let description: String?
    public let recommendations: [UnmanagedRecommendation]

    public struct UnmanagedRecommendation: Identifiable, Equatable, Hashable {
        public let id: String?
        public let item: UnmanagedItem
    }
}

private extension UnmanagedSlate {
    enum CodingKeys: String, CodingKey {
        case id
        case requestID = "requestId"
        case experimentID = "experimentId"
        case name
        case description
        case recommendations
    }
}

public struct UnmanagedSlateLineup: Identifiable, Equatable, Hashable {
    public let id: String
    public let requestID: String
    public let experimentID: String
    public let slates: [UnmanagedSlate]
}
