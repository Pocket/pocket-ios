import Sync
import Combine
import Foundation
import Textile


class SavedItemViewModel: ReadableViewModel {
    weak var delegate: ReadableViewModelDelegate? = nil

    @Published
    private var _actions: [ReadableAction] = []
    var actions: Published<[ReadableAction]>.Publisher { $_actions }

    var components: [ArticleComponent]? {
        item.item?.article?.components
    }

    var textAlignment: Textile.TextAlignment {
        item.textAlignment
    }

    var title: String? {
        item.item?.title
    }

    var authors: [ReadableAuthor]? {
        item.item?.authors?.compactMap { $0 as? Author }
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

    private var source: Source
    private var favoriteSubscription: AnyCancellable? = nil

    private let item: SavedItem

    init(item: SavedItem, source: Source) {
        self.item = item
        self.source = source

        favoriteSubscription = item.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }

        buildActions()
    }

    func favorite() {
        source.favorite(item: item)
        delegate?.readableViewModelDidFavorite(self)
    }

    func unfavorite() {
        source.unfavorite(item: item)
        delegate?.readableViewModelDidUnfavorite(self)
    }

    func archive() {
        source.archive(item: item)
        delegate?.readableViewModelDidArchive(self)
    }

    func delete() {
        source.delete(item: item)
        delegate?.readableViewModelDidDelete(self)
    }

    func shareActivity(additionalText: String?) -> PocketItemActivity? {
        PocketItemActivity(url: url, additionalText: additionalText)
    }

    private func buildActions() {
        if item.isFavorite {
            _actions = [
                .unfavorite { [weak self] in self?.unfavorite() },
                .archive { [weak self] in self?.archive() },
                .delete { [weak self] in self?.delete() }
            ]
        } else {
            _actions = [
                .favorite { [weak self] in self?.favorite() },
                .archive { [weak self] in self?.archive() },
                .delete { [weak self] in self?.delete() }
            ]
        }
    }
}

