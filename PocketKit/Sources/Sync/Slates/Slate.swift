import Foundation


public struct Slate: Identifiable, Equatable, Hashable {
    public let id: String
    public let requestID: String
    public let experimentID: String
    public let name: String?
    public let description: String?
    public let recommendations: [Recommendation]

    public struct Recommendation: Identifiable, Equatable, Hashable {
        public let id: String?
        public let item: UnmanagedItem
    }
}

private extension Slate {
    enum CodingKeys: String, CodingKey {
        case id
        case requestID = "requestId"
        case experimentID = "experimentId"
        case name
        case description
        case recommendations
    }
}

public struct SlateLineup: Identifiable, Equatable, Hashable {
    public let id: String
    public let requestID: String
    public let experimentID: String
    public let slates: [Slate]
}
