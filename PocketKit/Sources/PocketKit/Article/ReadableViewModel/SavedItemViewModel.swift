// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import Foundation
import Textile
import Analytics
import UIKit
import SharedPocketKit
import Localization

class SavedItemViewModel: ReadableViewModel {
    func trackReadingProgress(index: IndexPath) {
        let baseKey = readingProgressKeyBase(url: item.url)

        userDefaults.setValue(index.section, forKey: baseKey + "section")
        userDefaults.setValue(index.row, forKey: baseKey + "row")
    }

    func readingProgress() -> IndexPath? {
        let baseKey = readingProgressKeyBase(url: item.url)

        guard let section = userDefaults.object(forKey: baseKey + "section") as? Int,
              let row = userDefaults.object(forKey: baseKey + "row") as? Int else {
            return nil
        }

        return IndexPath(row: row, section: section)
    }

    func deleteReadingProgress() {
        let baseKey = readingProgressKeyBase(url: item.url)

        userDefaults.removeObject(forKey: baseKey + "section")
        userDefaults.removeObject(forKey: baseKey + "row")
    }

    private func readingProgressKeyBase(url: URL) -> String {
        "readingProgress.\(url.absoluteString)."
    }

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
    private let notificationCenter: NotificationCenter

    init(
        item: SavedItem,
        source: Source,
        tracker: Tracker,
        pasteboard: Pasteboard,
        user: User,
        store: SubscriptionStore,
        networkPathMonitor: NetworkPathMonitor,
        userDefaults: UserDefaults,
        notificationCenter: NotificationCenter
    ) {
        self.item = item
        self.source = source
        self.tracker = tracker
        self.pasteboard = pasteboard
        self.user = user
        self.store = store
        self.networkPathMonitor = networkPathMonitor
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter

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

    var url: String {
        item.bestURL
    }

    var isArchived: Bool {
        item.isArchived
    }

    var premiumURL: String? {
        pocketPremiumURL(url, user: user)
    }

    func moveToSaves() {
        source.unarchive(item: item)
    }

    func delete() {
        deleteReadingProgress()
        source.delete(item: item)
        _events.send(.delete)
    }

    func fetchDetailsIfNeeded() {
        guard item.item?.article == nil else {
            _events.send(.contentUpdated)
            return
        }

        Task {
            do {
                let remoteHasArticle = try await self.source.fetchDetails(for: self.item)
                displayArticle(with: remoteHasArticle)
            } catch {
                Log.capture(message: "Failed to fetch details for SavedItemViewModel: \(error)")
            }
        }
    }

    /// Check to see if item has article components to display in reader view, else display in web view
    /// - Parameter remoteHasArticle: condition if the remote in `fetchDetails` has article data
    private func displayArticle(with remoteHasArticle: Bool) {
        if let itemDetails = item.item, itemDetails.hasArticleComponents || remoteHasArticle {
            _events.send(.contentUpdated)
        } else {
            showWebReader()
        }
    }

    func externalActions(for url: URL) -> [ItemAction] {
        [
            .save { [weak self] _ in self?.saveExternalURL(url) },
            .open { [weak self] _ in self?.openExternalLink(url: url) },
            .copyLink { [weak self] _ in self?.copyExternalURL(url) },
            .share { [weak self] _ in self?.shareExternalURL(url) }
        ]
    }

    func webViewActivityItems(url: URL) -> [UIActivity] {
        guard let item = source.fetchItem(url.absoluteString), let savedItem = item.savedItem else {
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
            tagsAction(),
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() }
        ]
    }

    func favorite() {
        source.favorite(item: item)
        trackFavorite(url: item.url)
    }

    func unfavorite() {
        source.unfavorite(item: item)
        trackUnfavorite(url: item.url)
    }

    func moveFromArchiveToSaves(completion: (Bool) -> Void) {
        source.unarchive(item: item)
        trackMoveFromArchiveToSavesButtonTapped(url: item.url)
        completion(true)
    }

    func openInWebView(url: String) {
        guard let url = URL(percentEncoding: url) else { return }
        let updatedURL = pocketPremiumURL(url, user: user)
        presentedWebReaderURL = updatedURL

        trackWebViewOpen()
    }

    func openExternalLink(url: URL) {
        let updatedURL = pocketPremiumURL(url, user: user)
        presentedWebReaderURL = updatedURL

        trackExternalLinkOpen(url: url.absoluteString)
    }

    func archive() {
        source.archive(item: item)
        trackArchiveButtonTapped(url: item.url)
        _events.send(.archive)
    }

    func beginBulkEdit() {
        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: nil,
            detail: Localization.Search.Edit.banner
        )

        notificationCenter.post(name: .bannerRequested, object: bannerData)
    }

    private func tagsAction() -> ItemAction {
        let hasTags = (item.tags?.count ?? 0) > 0
        if hasTags {
            return .editTags { [weak self] _ in self?.showAddTagsView() }
        } else {
            return .addTags { [weak self] _ in self?.showAddTagsView() }
        }
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
        trackAddTags(url: item.url)
    }

    private func saveExternalURL(_ url: URL) {
        source.save(url: url.absoluteString)
    }

    private func copyExternalURL(_ url: URL) {
        pasteboard.url = url
    }

    private func shareExternalURL(_ url: URL) {
        // This view model is used within the context of a view that is presented within the reader
        sharedActivity = PocketItemActivity.fromReader(url: url.absoluteString)
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
