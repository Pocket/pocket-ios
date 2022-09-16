import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics

class SharedWithYouViewModel: ReadableViewModel {
    @Published
    private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var isPresentingReaderSettings: Bool?

    private let sharedWithYouHighlight: SharedWithYouHighlight
    private let source: Source
    let tracker: Tracker

    private var savedItemCancellable: AnyCancellable?
    private var savedItemSubscriptions: Set<AnyCancellable> = []

    init(sharedWithYouHighlight: SharedWithYouHighlight, source: Source, tracker: Tracker) {
        self.sharedWithYouHighlight = sharedWithYouHighlight
        self.source = source
        self.tracker = tracker

        self.savedItemCancellable = sharedWithYouHighlight.item?.publisher(for: \.savedItem).sink { [weak self] savedItem in
            self?.update(for: savedItem)
        }
    }

    var components: [ArticleComponent]? {
        sharedWithYouHighlight.item?.article?.components
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings()
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: sharedWithYouHighlight.item?.language)
    }

    var title: String? {
        sharedWithYouHighlight.item?.title
    }

    var authors: [ReadableAuthor]? {
        sharedWithYouHighlight.item?.authors?.compactMap { $0 as? Author}
    }

    var domain: String? {
        sharedWithYouHighlight.item?.domainMetadata?.name ?? sharedWithYouHighlight.item?.domain ?? sharedWithYouHighlight.item?.bestURL?.host
    }

    var publishDate: Date? {
        sharedWithYouHighlight.item?.datePublished
    }

    var url: URL? {
        sharedWithYouHighlight.item?.bestURL
    }

    func moveToMyList() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            return
        }

        source.unarchive(item: savedItem)
    }

    func delete() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            return
        }

        source.delete(item: savedItem)
        _events.send(.delete)
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }

    func fetchDetailsIfNeeded() {
        guard sharedWithYouHighlight.item?.article == nil else {
            _events.send(.contentUpdated)
            return
        }

        Task {
            try await source.fetchDetails(for: sharedWithYouHighlight)
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
}

extension SharedWithYouViewModel {
    private func buildActions() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            _actions = [
                .displaySettings { [weak self] _ in self?.displaySettings() },
                .save { [weak self] _ in self?.save() },
                .share { [weak self] _ in self?.share() },
            ]

            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite() }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite() }
        }

        let archiveAction: ItemAction
        if savedItem.isArchived {
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

    private func subscribe(to savedItem: SavedItem?) {
        savedItem?.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &savedItemSubscriptions)

        savedItem?.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &savedItemSubscriptions)
    }

    private func update(for savedItem: SavedItem?) {
        if savedItem == nil {
            savedItemSubscriptions = []
        }

        buildActions()
        subscribe(to: savedItem)
    }

    private func favorite() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            return
        }

        source.favorite(item: savedItem)
        track(identifier: .itemFavorite)
    }

    private func unfavorite() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            return
        }

        source.unfavorite(item: savedItem)
        track(identifier: .itemUnfavorite)
    }

    private func archive() {
        guard let savedItem = sharedWithYouHighlight.item?.savedItem else {
            return
        }

        source.archive(item: savedItem)
        track(identifier: .itemArchive)
        _events.send(.archive)
    }

    private func save() {
        source.save(sharedWithYouHighlight: sharedWithYouHighlight)
        track(identifier: .itemSave)
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

extension SharedWithYouViewModel {
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
