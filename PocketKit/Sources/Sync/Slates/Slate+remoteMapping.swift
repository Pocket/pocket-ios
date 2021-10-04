import Foundation


extension Slate {
    typealias Remote = SlateParts

    init(remote: Remote) {
        self.init(
            id: remote.id,
            name: remote.displayName,
            description: remote.description,
            recommendations: remote.recommendations.map(Slate.Recommendation.init)
        )
    }
}

extension Slate.Recommendation {
    typealias Remote = SlateParts.Recommendation

    init(remote: Remote) {
        self.init(
            id: remote.id,
            item: Slate.Item(remote: remote.item.fragments.itemParts)
        )
    }
}

extension Slate.Item {
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
            particleJSON: remote.particleJson,
            excerpt: remote.excerpt,
            domain: remote.domain,
            domainMetadata: (remote.domainMetadata?.fragments.domainMetadataParts).flatMap(Slate.DomainMetadata.init)
        )
    }
}

extension Slate.DomainMetadata {
    typealias Remote = DomainMetadataParts

    init(remote: Remote) {
        self.init(
            name: remote.name,
            logo: remote.logo.flatMap(URL.init)
        )
    }
}

