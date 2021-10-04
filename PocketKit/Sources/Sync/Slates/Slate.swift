import Foundation


public struct Slate: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String?
    public let description: String?
    public let recommendations: [Recommendation]

    public struct Recommendation: Identifiable, Equatable, Hashable {
        public let id: String?
        public let item: Slate.Item
    }

    public struct DomainMetadata: Equatable, Hashable {
        public let name: String?
        public let logo: URL?
    }

    public struct Item: Equatable, Hashable {
        public let id: String
        public let givenURL: URL?
        public let resolvedURL: URL?
        public let title: String?
        public let language: String?
        public let topImageURL: URL?
        public let timeToRead: Int?
        public let particleJSON: String?
        public let excerpt: String?
        public let domain: String?
        public let domainMetadata: DomainMetadata?
    }
}
