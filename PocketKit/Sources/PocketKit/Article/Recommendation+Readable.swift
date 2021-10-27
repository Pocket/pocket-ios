import Foundation
import Textile
import Sync


extension Slate.Recommendation: Readable {
    var title: String? {
        item.title
    }

    var authors: [ReadableAuthor]? {
        item.authors
    }

    var domain: String? {
        item.domainMetadata?.name ?? item.domain
    }

    var publishDate: Date? {
        item.datePublished
    }

    var components: [ArticleComponent]? {
        item.article?.components
    }

    var readerURL: URL? {
        item.resolvedURL ?? item.givenURL
    }

    var textAlignment: TextAlignment {
        TextAlignment(language: item.language)
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(recommendation: self, additionalText: additionalText)
    }
}

extension Slate.Author: ReadableAuthor {
    
}
