import Sync
import Foundation


extension SavedItem: Readable {
    var title: String? {
        item?.title
    }

    var author: String? {
        item?.authors?.compactMap { ($0 as? Author)?.name }.joined(separator: " and ")
    }

    var domain: String? {
        item?.domainMetadata?.name ?? item?.domain
    }

    var publishDate: Date? {
        item?.datePublished
    }

    var components: [ArticleComponent]? {
        item?.marticleJSON.flatMap {
            try? JSONDecoder().decode([ArticleComponent].self, from: $0)
        }
    }

    var readerURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(item: self, additionalText: additionalText)
    }
}
