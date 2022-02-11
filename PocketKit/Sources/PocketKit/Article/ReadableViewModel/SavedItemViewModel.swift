import Sync
import Combine
import Foundation
import Textile
import Analytics
import UIKit


class SavedItemViewModel: ReadableViewModel {
    let tracker: Tracker

    @Published
    private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }
    
    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var isPresentingReaderSettings: Bool?

    private let item: SavedItem
    private let source: Source
    private var subscriptions: [AnyCancellable] = []

    init(
        item: SavedItem,
        source: Source,
        tracker: Tracker
    ) {
        self.item = item
        self.source = source
        self.tracker = tracker

        item.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)

        item.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings()
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
        item.bestURL
    }
    
    func unarchive() {
        source.unarchive(item: item)
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
        _events.send(.archive)
    }

    func delete() {
        source.delete(item: item)
        _events.send(.delete)
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }
}

extension SavedItemViewModel {
    private func buildActions() {
        let favoriteAction: ItemAction
        if item.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite() }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite() }
        }

        let archiveAction: ItemAction
        if item.isArchived {
            archiveAction = .reAdd { [weak self] _ in self?.unarchive() }
        } else {
            archiveAction = .archive { [weak self] _ in self?.archive() }
        }

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            favoriteAction,
            archiveAction,
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() }
        ]
    }
}
