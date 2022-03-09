import Foundation


public struct UnmanagedItem: Equatable, Hashable {
    public let id: String
    public let givenURL: URL?
    public let resolvedURL: URL?
    public let title: String?
    public let language: String?
    public let topImageURL: URL?
    public let timeToRead: Int?
    public let article: Article?
    public let excerpt: String?
    public let domain: String?
    public let domainMetadata: DomainMetadata?
    public let authors: [Author]?
    public let datePublished: Date?
    public let images: [Image]?
    public let isArticle: Bool
    public let imageness: String?
    public let videoness: String?

    public struct DomainMetadata: Equatable, Hashable {
        public let name: String?
        public let logo: URL?
    }

    public struct Author: Equatable, Hashable {
        public let id: String
        public let name: String?
        public let url: URL?
    }

    public struct Image: Equatable, Hashable {
        public let height: Int?
        public let width: Int?
        public let src: URL?
        public let imageID: Int?
    }
}
