import Foundation
import Textile
import Sync


extension Slate.Recommendation: Readable {
    var particle: Article? {
        particleJSON?.data(using: .utf8).flatMap { data in
            try? JSONDecoder().decode(Article.self, from: data)
        }
    }

    var textAlignment: TextAlignment {
        TextAlignment(language: language)
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(recommendation: self, additionalText: additionalText)
    }
}
