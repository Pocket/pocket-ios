import Sync
import Combine
import Foundation
import Textile
import Analytics
import UIKit


class SavedItemViewModel: ReadableViewModel {
    @Published
    private var _actions: [ReadableAction] = []
    var actions: Published<[ReadableAction]>.Publisher { $_actions }
    
    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher {
        _events.eraseToAnyPublisher()
    }

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
    let mainViewModel: MainViewModel
    let tracker: Tracker
    
    private var favoriteSubscription: AnyCancellable? = nil

    private let item: SavedItem

    init(
        item: SavedItem,
        source: Source,
        mainViewModel: MainViewModel,
        tracker: Tracker
    ) {
        self.item = item
        self.source = source
        self.mainViewModel = mainViewModel
        self.tracker = tracker

        favoriteSubscription = item.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }

        buildActions()
    }
    
    func delete() {
        source.delete(item: self.item)
        _events.send(.delete)
    }
}

extension SavedItemViewModel {
    private func buildActions() {
        if item.isFavorite {
            _actions = [
                .displaySettings { [weak self] in self?.displaySettings() },
                .unfavorite { [weak self] in self?.unfavorite() },
                .archive { [weak self] in self?.archive() },
                .delete { [weak self] in self?.confirmDelete() },
                .share { [weak self] in self?.share() }
            ]
        } else {
            _actions = [
                .displaySettings { [weak self] in self?.displaySettings() },
                .favorite { [weak self] in self?.favorite() },
                .archive { [weak self] in self?.archive() },
                .delete { [weak self] in self?.confirmDelete() },
                .share { [weak self] in self?.share() }
            ]
        }
    }
    
    private func favorite() {
        source.favorite(item: item)
        track(identifier: .itemFavorite)
    }

    private func unfavorite() {
        source.unfavorite(item: item)
        track(identifier: .itemUnfavorite)
    }

    private func archive() {
        source.archive(item: item)
        track(identifier: .itemArchive)
    }
}
