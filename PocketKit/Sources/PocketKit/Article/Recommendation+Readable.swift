import Foundation
import Textile
import Sync


extension Slate.Recommendation: Readable {
    var readerURL: URL? {
        item.resolvedURL ?? item.givenURL
    }

    var particleJSON: String? {
        item.particleJSON
    }

    var textAlignment: TextAlignment {
        TextAlignment(language: item.language)
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(recommendation: self, additionalText: additionalText)
    }
}
