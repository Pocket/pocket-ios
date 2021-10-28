import Sync
import Foundation
import Textile


protocol Readable {
    var components: [ArticleComponent]? { get }
    var readerURL: URL? { get }
    var textAlignment: TextAlignment { get }

    var title: String? { get }
    var authors: [ReadableAuthor]? { get }
    var domain: String? { get }
    var publishDate: Date? { get }

    func shareActivity(additionalText: String?) -> PocketActivity?
}

protocol ReadableAuthor {
    var name: String? { get }
}
