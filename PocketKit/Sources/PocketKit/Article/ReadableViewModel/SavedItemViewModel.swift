import Sync
import Combine
import Foundation
import Textile
import Analytics
import UIKit
import SharedPocketKit

class SavedItemViewModel: ReadableViewModel {
    let tracker: Tracker

    @Published private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published var presentedAlert: PocketAlert?

    @Published var presentedWebReaderURL: URL?

    @Published var presentedAddTags: PocketAddTagsViewModel?

    @Published var sharedActivity: PocketActivity?

    @Published var isPresentingReaderSettings: Bool?

    private let item: SavedItem
    private let source: Source
    private let pasteboard: Pasteboard
    private let user: User
    private let userDefaults: UserDefaults
    private var subscriptions: [AnyCancellable] = []
    private var store: SubscriptionStore
    private var networkPathMonitor: NetworkPathMonitor

    init(
        item: SavedItem,
        source: Source,
        tracker: Tracker,
        pasteboard: Pasteboard,
        user: User,
        store: SubscriptionStore,
        networkPathMonitor: NetworkPathMonitor,
        userDefaults: UserDefaults
    ) {
        self.item = item
        self.source = source
        self.tracker = tracker
        self.pasteboard = pasteboard
        self.user = user
        self.store = store
        self.networkPathMonitor = networkPathMonitor
        self.userDefaults = userDefaults

        item.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)

        item.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings(userDefaults: userDefaults)
    }

    var components: [ArticleComponent]? {
        item.item.article?.components
    }

    var textAlignment: Textile.TextAlignment {
        item.textAlignment
    }

    var title: String? {
        item.item.title
    }

    var authors: [ReadableAuthor]? {
        item.item.authors?.compactMap { $0 as? Author }
    }

    var domain: String? {
        item.item.domainMetadata?.name ?? item.item.domain ?? item.host
    }

    var publishDate: Date? {
        item.item.datePublished
    }

    var url: URL? {
        item.bestURL
    }

    var isArchived: Bool {
        item.isArchived
    }

    var premiumURL: URL? {
        pocketPremiumURL(url, user: user)
    }

    func moveToSaves() {
        source.unarchive(item: item)
    }

    func delete() {
        source.delete(item: item)
        _events.send(.delete)
    }

    func fetchDetailsIfNeeded() {
        guard item.item.article == nil else {
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

    func webViewActivityItems(url: URL) -> [UIActivity] {
        guard let item = source.fetchItem(url), let savedItem = item.savedItem else {
            return []
        }

        return webViewActivityItems(for: savedItem)
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

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            favoriteAction,
            .addTags { [weak self] _ in self?.showAddTagsView() },
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() }
        ]
    }

    func favorite() {
        source.favorite(item: item)
        track(identifier: .itemFavorite)
    }

    func unfavorite() {
        source.unfavorite(item: item)
        track(identifier: .itemUnfavorite)
    }

    func moveFromArchiveToSaves(completion: (Bool) -> Void) {
        source.unarchive(item: item)
        trackMoveFromArchiveToSavesButtonTapped(url: item.url)
        completion(true)
    }

    func openExternally(url: URL?) {
        let updatedURL = pocketPremiumURL(url, user: user)
        presentedWebReaderURL = updatedURL

        trackWebViewOpen()
    }

    func archive() {
        source.archive(item: item)
        trackArchiveButtonTapped(url: item.url)
        _events.send(.archive)
    }

    private func showAddTagsView() {
        presentedAddTags = PocketAddTagsViewModel(
            item: item,
            source: source,
            tracker: tracker,
            userDefaults: userDefaults,
            user: user,
            store: store,
            networkPathMonitor: networkPathMonitor,
            saveAction: { [weak self] in
                self?.fetchDetailsIfNeeded()
            }
        )
        track(identifier: .itemAddTags)
    }

    private func saveExternalURL(_ url: URL) {
        source.save(url: url)
    }

    private func copyExternalURL(_ url: URL) {
        pasteboard.url = url
    }

    private func shareExternalURL(_ url: URL) {
        // This view model is used within the context of a view that is presented within the reader
        sharedActivity = PocketItemActivity.fromReader(url: url)
    }

    private func openExternalURL(_ url: URL) {
        presentedWebReaderURL = url
    }
}

extension SavedItemViewModel {
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
