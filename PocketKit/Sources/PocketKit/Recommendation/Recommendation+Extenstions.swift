import Foundation
import Sync

extension Recommendation {
    var bestImageURL: URL? {
        guard let topImageURL = imageURL ?? item.syndicatedArticle?.imageURL ?? item.topImageURL ?? (item.images?.firstObject as? Image)?.source else {
            return nil
        }

        return imageCacheURL(for: topImageURL)
    }

    var bestDomain: String? {
        item.syndicatedArticle?.publisherName
        ?? item.domainMetadata?.name
        ?? item.domain
        ?? URL(string: item.bestURL)?.host
        ?? "" // TODO: What should be the final fallback string?
    }

    var bestTitle: String? {
        title ?? item.syndicatedArticle?.title ?? item.title
    }

    var bestExcerpt: String? {
        excerpt ?? item.syndicatedArticle?.excerpt ?? item.excerpt
    }
}
