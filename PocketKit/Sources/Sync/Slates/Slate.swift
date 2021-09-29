import Foundation


public struct Slate: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String?
    public let description: String?
    public let recommendations: [Recommendation]

    public struct Recommendation: Identifiable, Equatable, Hashable {
        public let id: String?
        public let url: URL?
        public let itemID: String
        public let feedID: Int?
        public let publisher: String?
        public let source: String
        public let title: String?
        public let language: String?
        public let topImageURL: URL?
        public let timeToRead: Int?
        public let particleJSON: String?
        public let domain: String?
        public let domainMetadata: DomainMetadata?
        public let excerpt: String?
    }

    public struct DomainMetadata: Equatable, Hashable {
        public let name: String?
    }
}
