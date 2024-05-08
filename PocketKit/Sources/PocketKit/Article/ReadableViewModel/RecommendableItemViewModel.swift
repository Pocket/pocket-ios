// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics
import SharedPocketKit

class RecommendableItemViewModel: ReadableViewModel {
    weak var delegate: ReadableViewModelDelegate?

    @Published private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published var presentedAlert: PocketAlert?

    @Published var sharedActivity: PocketActivity?

    @Published var presentedWebReaderURL: URL?

    @Published var isPresentingReaderSettings: Bool?

    @Published var selectedItemToReport: Item?

    let readableSource: ReadableSource

    private let item: Item
    private let source: Source
    private let pasteboard: Pasteboard
    private let user: User
    private let userDefaults: UserDefaults
    let tracker: Tracker

    private var savedItemCancellable: AnyCancellable?
    private var savedItemSubscriptions: Set<AnyCancellable> = []

    init(
        item: Item,
        source: Source,
        tracker: Tracker,
        pasteboard: Pasteboard,
        user: User,
        userDefaults: UserDefaults,
        readableSource: ReadableSource = .app
    ) {
        self.item = item
        self.source = source
        self.tracker = tracker
        self.pasteboard = pasteboard
        self.user = user
        self.userDefaults = userDefaults
        self.readableSource = readableSource

        self.savedItemCancellable = item.publisher(for: \.savedItem).sink { [weak self] savedItem in
            self?.update(for: savedItem)
        }

        if let url = item.shareURL {
            shareUrl = url
        } else {
            Task {
                shareUrl = try? await source.requestShareUrl(item.givenURL)
            }
        }
    }

    var components: [ArticleComponent]? {
        item.article?.components
    }

    lazy var readerSettings: ReaderSettings = {
        ReaderSettings(tracker: tracker, userDefaults: userDefaults)
    }()

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: item.language)
    }

    var title: String? {
        item.syndicatedArticle?.title ?? item.title
    }

    var authors: [ReadableAuthor]? {
        item.authors?.compactMap { $0 as? Author }
    }

    var domain: String? {
        item.bestDomain
    }

    var publishDate: Date? {
        item.datePublished
    }

    // TODO: Can this be converted from URL? -> String?
    var url: String {
        item.bestURL
    }

    var shareUrl: String?

    var itemSaveStatus: ItemSaveStatus {
        guard let savedItem = item.savedItem else {
            return .unsaved
        }
        if savedItem.isArchived {
            return .archived
        }
        return .saved
    }

    var premiumURL: String? {
        pocketPremiumURL(url, user: user)
    }

    var isListenSupported: Bool {
        false
    }

    func moveToSaves() {
        guard let savedItem = item.savedItem else {
            return
        }

        source.unarchive(item: savedItem)
    }

    func delete() {
        guard let savedItem = item.savedItem else {
            return
        }

        source.delete(item: savedItem)
        _events.send(.delete)
    }

    func fetchDetailsIfNeeded() {
        guard item.article == nil else {
            _events.send(.contentUpdated)
            return
        }

        Task {
            do {
                let remoteHasArticle = try await source.fetchDetails(for: item)
                displayArticle(with: remoteHasArticle)
            } catch {
                Log.capture(message: "Failed to fetch details for RecommendationViewModel: \(error)")
            }
        }
    }

    // MARK: Reader Progress

    func trackReadingProgress(index: IndexPath) {
        guard let baseKey = readingProgressKeyBase(url: url) else {
            return
        }

        userDefaults.setValue(index.section, forKey: baseKey + "section")
        userDefaults.setValue(index.row, forKey: baseKey + "row")
    }

    func readingProgress() -> IndexPath? {
        guard let baseKey = readingProgressKeyBase(url: url) else {
            return nil
        }

        guard let section = userDefaults.object(forKey: baseKey + "section") as? Int,
              let row = userDefaults.object(forKey: baseKey + "row") as? Int else {
            return nil
        }

        return IndexPath(row: row, section: section)
    }

    func deleteReadingProgress() {
        guard let baseKey = readingProgressKeyBase(url: url) else {
            return
        }

        userDefaults.removeObject(forKey: baseKey + "section")
        userDefaults.removeObject(forKey: baseKey + "row")
    }

    private func readingProgressKeyBase(url: String?) -> String? {
        guard let url else { return nil }

        return "readingProgress.\(url)."
    }

    /// Check to see if item has article components to display in reader view, else display in web view
    /// - Parameter remoteHasArticle: condition if the remote in `fetchDetails` has article data
    private func displayArticle(with remoteHasArticle: Bool) {
        if item.hasArticleComponents || remoteHasArticle {
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
        guard let item = source.fetchItem(url.absoluteString) else {
            return []
        }

        if !item.isSaved {
            // When recommendation is Not saved
            let saveActivity = ReaderActionsWebActivity(title: .save) { [weak self] in
                if item.isSaved {
                    self?.archive()
                } else {
                    self?.save(completion: { _ in })
                }
            }

            let reportActivity = ReaderActionsWebActivity(title: .report) { [weak self] in
                self?.report()
            }
            return [saveActivity, reportActivity]
        } else {
            // When recommendation is saved
            guard let savedItem = item.savedItem else {
                return []
            }
            return webViewActivityItems(for: savedItem)
        }
    }

    func listen() { }
}

extension RecommendableItemViewModel {
    private func buildActions() {
        guard let savedItem = item.savedItem else {
            _actions = [
                .displaySettings { [weak self] _ in self?.displaySettings() },
                .save { [weak self] _ in self?.save(completion: { _ in }) },
                .share { [weak self] _ in self?.share() },
                .report { [weak self] _ in self?.report() }
            ]

            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite() }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite() }
        }

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            favoriteAction,
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

    private func report() {
        selectedItemToReport = item
        trackReport()
    }

    func favorite() {
        guard let savedItem = item.savedItem else {
            return
        }

        source.favorite(item: savedItem)
        trackFavorite(url: savedItem.url)
    }

    func unfavorite() {
        guard let savedItem = item.savedItem else {
            return
        }

        source.unfavorite(item: savedItem)
        trackUnfavorite(url: savedItem.url)
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

    func moveFromArchiveToSaves(completion: (Bool) -> Void) {
        guard let savedItem = item.savedItem else {
            Log.capture(message: "Could not get SavedItem so unarchive action not taken")
            completion(false)
            return
        }
        source.unarchive(item: savedItem)
        trackMoveFromArchiveToSavesButtonTapped(url: savedItem.url)
        completion(true)
    }

    func archive() {
        guard let savedItem = item.savedItem else {
            Log.capture(message: "Could not get SavedItem so archive action not taken")
            return
        }

        source.archive(item: savedItem)
        trackArchiveButtonTapped(url: savedItem.url)
        _events.send(.archive)
    }

    func beginBulkEdit() {
    }

    func save(completion: (Bool) -> Void) {
        source.save(item: item)
        trackSave()
        completion(true)
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

extension RecommendableItemViewModel {
    func clearPresentedWebReaderURL() {
        presentedWebReaderURL = nil
    }

    func clearIsPresentingReaderSettings() {
        isPresentingReaderSettings = false
    }

    func clearSharedActivity() {
        sharedActivity = nil
    }

    func clearSelectedRecommendationToReport() {
        selectedItemToReport = nil
    }
}
