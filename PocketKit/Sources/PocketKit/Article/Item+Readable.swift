import Sync
import Foundation


extension SavedItem: Readable {
    var authors: [ReadableAuthor]? {
        item?.authors?.compactMap { $0 as? Author }
    }

    var title: String? {
        item?.title
    }

    var domain: String? {
        item?.domainMetadata?.name ?? item?.domain
    }

    var publishDate: Date? {
        item?.datePublished
    }

    var components: [ArticleComponent]? {
        item?.article?.components
    }

    var readerURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(item: self, additionalText: additionalText)
    }
}

extension Author: ReadableAuthor {
}
