@testable import Sync


extension UnmanagedItem {
    static func build(id: String = "item-1") -> UnmanagedItem {
        return UnmanagedItem(
            id: id,
            givenURL: nil,
            resolvedURL: nil,
            title: nil,
            language: nil,
            topImageURL: nil,
            timeToRead: nil,
            article: nil,
            excerpt: nil,
            domain: nil,
            domainMetadata: nil,
            authors: nil,
            datePublished: nil,
            images: nil,
            isArticle: false,
            imageness: "HAS_IMAGES",
            videoness: "HAS_VIDEOS"
        )
    }
}
