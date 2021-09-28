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
            itemID: remote.itemId,
            feedID: remote.feedId,
            publisher: remote.publisher,
            source: remote.recSrc,
            title: remote.item.title,
            language: remote.item.language,
            topImageURL: remote.item.topImageUrl.flatMap { URL(string: $0) },
            timeToRead: remote.item.timeToRead,
            particleJSON: remote.item.particleJson,
            domain: remote.item.domain,
            domainMetadata: Slate.DomainMetadata(remote: remote.item.domainMetadata),
            excerpt: remote.item.excerpt
        )
    }
}

extension Slate.DomainMetadata {
    typealias Remote = Slate.Recommendation.Remote.Item.DomainMetadatum

    init?(remote: Remote?) {
        guard let remote = remote else {
            return nil
        }

        self.init(name: remote.name)
    }
}

