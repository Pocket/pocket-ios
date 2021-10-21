import Foundation
import Textile
import Sync


extension Slate.Recommendation: Readable {
    var title: String? {
        nil
    }

    var author: String? {
        nil
    }

    var domain: String? {
        nil
    }

    var publishDate: Date? {
        nil
    }

    var components: [ArticleComponent]? {
        []
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
