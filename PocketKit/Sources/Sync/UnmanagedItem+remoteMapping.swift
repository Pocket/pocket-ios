import Foundation


extension UnmanagedItem {
    typealias Remote = ItemParts

    init(remote: Remote) {
        self.init(
            id: remote.remoteId,
            givenURL: URL(string: remote.givenUrl),
            resolvedURL: remote.resolvedUrl.flatMap(URL.init),
            title: remote.title,
            language: remote.language,
            topImageURL: remote.topImageUrl.flatMap(URL.init),
            timeToRead: remote.timeToRead,
            article: remote.marticle.flatMap {
                Article(components: $0.map(ArticleComponent.init))
            },
            excerpt: remote.excerpt,
            domain: remote.domain,
            domainMetadata: (remote.domainMetadata?.fragments.domainMetadataParts).flatMap(DomainMetadata.init),
            authors: remote.authors.flatMap { $0.compactMap { $0 }.map(Author.init) },
            datePublished: remote.datePublished.flatMap { DateFormatter.clientAPI.date(from: $0) },
            images: remote.images.flatMap { $0.compactMap { $0 }.map(Image.init) },
            isArticle: remote.isArticle ?? false,
            imageness: remote.hasImage?.rawValue,
            videoness: remote.hasVideo?.rawValue
        )
    }
}

extension UnmanagedItem.DomainMetadata {
    typealias Remote = DomainMetadataParts

    init(remote: Remote) {
        self.init(
            name: remote.name,
            logo: remote.logo.flatMap(URL.init)
        )
    }
}

extension UnmanagedItem.Author {
    typealias Remote = ItemParts.Author

    init(remote: Remote) {
        self.init(
            id: remote.id,
            name: remote.name,
            url: remote.url.flatMap(URL.init)
        )
    }
}

extension UnmanagedItem.Image {
    typealias Remote = ItemParts.Image

    init(remote: Remote) {
        self.init(
            height: remote.height,
            width: remote.width,
            src: URL(string: remote.src),
            imageID: remote.imageId
        )
    }
}
