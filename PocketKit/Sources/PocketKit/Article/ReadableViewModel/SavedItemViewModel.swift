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
        item.item?.domainMetadata?.name ?? item.item?.domain ?? item.host
    }

    var publishDate: Date? {
        item.item?.datePublished
    }

    var url: URL? {
        item.bestURL
    }
    
    func moveToMyList() {
        source.unarchive(item: item)
    }

    func delete() {
        source.delete(item: item)
        _events.send(.delete)
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }

    func fetchDetailsIfNeeded() {
        guard item.item?.article == nil else {
            _events.send(.contentUpdated)
            return
        }

        Task {
            try? await self.source.fetchDetails(for: self.item)
            _events.send(.contentUpdated)
        }
    }
    
    func externalActions(for url: URL) -> [ItemAction] {
        [
            .save { [weak self] _ in self?.saveExternalURL(url) },
            .open { [weak self] _ in self?.openExternalURL(url) },
            .copyLink { [weak self] _ in self?.copyExternalURL(url) },
            .share { [weak self] _ in self?.shareExternalURL(url) }
        ]
    }

    func clearPresentedWebReaderURL() {
        presentedWebReaderURL = nil
    }

    func clearIsPresentingReaderSettings() {
        isPresentingReaderSettings = false
    }

    func clearSharedActivity() {
        sharedActivity = nil
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
            archiveAction = .moveToMyList { [weak self] _ in self?.moveToMyList() }
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

    private func saveExternalURL(_ url: URL) {
        source.save(url: url)
    }

    private func copyExternalURL(_ url: URL) {
        UIPasteboard.general.url = url
    }

    private func shareExternalURL(_ url: URL) {
        sharedActivity = PocketItemActivity(url: url)
    }

    private func openExternalURL(_ url: URL) {
        presentedWebReaderURL = url
    }
}
