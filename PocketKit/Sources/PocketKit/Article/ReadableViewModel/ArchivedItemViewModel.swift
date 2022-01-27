import Combine
import Sync
import Foundation
import Textile
import UIKit


class ArchivedItemViewModel: ReadableViewModel {
    weak var delegate: ReadableViewModelDelegate? = nil

    @Published
    private var _actions: [ReadableAction] = []
    var actions: Published<[ReadableAction]>.Publisher { $_actions }

    var components: [ArticleComponent]? {
        item.item?.article?.components
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: item.item?.language)
    }

    var title: String? {
        item.item?.title
    }

    var authors: [ReadableAuthor]? {
        item.item?.authors
    }

    var domain: String? {
        item.item?.domainMetadata?.name ?? item.item?.domain
    }

    var publishDate: Date? {
        item.item?.datePublished
    }

    var url: URL? {
        item.item?.resolvedURL ?? item.item?.givenURL ?? item.url
    }

    private let item: ArchivedItem

    init(item: ArchivedItem) {
        self.item = item

        _actions = [
            .save { self.delegate?.readableViewModelDidSave(self) },
            .favorite { self.delegate?.readableViewModelDidFavorite(self) }
        ]
    }

    func shareActivity(additionalText: String?) -> PocketItemActivity? {
        PocketItemActivity(url: url, additionalText: additionalText)
    }

    func delete() { }
}
