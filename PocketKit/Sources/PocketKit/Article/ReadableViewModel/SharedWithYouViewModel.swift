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

class SharedWithYouHighlightViewModel: ReadableViewModel {
    @Published private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published var presentedAlert: PocketAlert?

    @Published var sharedActivity: PocketActivity?

    @Published var presentedWebReaderURL: URL?

    @Published var isPresentingReaderSettings: Bool?

    private let sharedWithYouHighlight: SharedWithYouHighlight
    private let source: Source
    private let pasteboard: Pasteboard
    private let user: User
    private let userDefaults: UserDefaults
    let tracker: Tracker

    var delegate: ReadableViewModelDelegate?

    var readableSource: ReadableSource = .app

    var isListenSupported: Bool = false

    var itemSaveStatus: ItemSaveStatus = .unsaved

    private var savedItemCancellable: AnyCancellable?
    private var savedItemSubscriptions: Set<AnyCancellable> = []

    init(sharedWithYouHighlight: SharedWithYouHighlight, source: Source, tracker: Tracker, pasteboard: Pasteboard, user: User, userDefaults: UserDefaults) {
        self.sharedWithYouHighlight = sharedWithYouHighlight
        self.source = source
        self.tracker = tracker
        self.pasteboard = pasteboard
        self.user = user
        self.userDefaults = userDefaults

//        self.savedItemCancellable = sharedWithYouHighlight.item.publisher(for: \.savedItem).sink { [weak self] savedItem in
//            self?.update(for: savedItem)
//        }
    }

    var components: [ArticleComponent]? {
        sharedWithYouHighlight.item.article?.components
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings(tracker: self.tracker, userDefaults: userDefaults)
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: sharedWithYouHighlight.item.language)
    }

    var title: String? {
        sharedWithYouHighlight.bestTitle
    }

    var authors: [ReadableAuthor]? {
        sharedWithYouHighlight.item.authors?.compactMap { $0 as? Author }
    }

    var domain: String? {
        sharedWithYouHighlight.bestDomain
    }

    var publishDate: Date? {
        sharedWithYouHighlight.item.datePublished
    }

    var url: String {
        sharedWithYouHighlight.item.bestURL
    }

    var isArchived: Bool {
        return sharedWithYouHighlight.item.savedItem?.isArchived ?? false
    }

    var premiumURL: String? {
        pocketPremiumURL(url, user: user)
    }

    func moveToSaves() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            return
        }

        source.unarchive(item: savedItem)
    }

    func delete() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            return
        }

        source.delete(item: savedItem)
        _events.send(.delete)
    }

    func fetchDetailsIfNeeded() {
        guard sharedWithYouHighlight.item.article == nil else {
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
                    self?.save()
                }
            }
            return [saveActivity]
        } else {
            // When recommendation is saved
            guard let savedItem = item.savedItem else {
                return []
            }
            return webViewActivityItems(for: savedItem)
        }
    }
}

extension SharedWithYouHighlightViewModel {
    private func buildActions() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
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

    func favorite() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            return
        }

        source.favorite(item: savedItem)
        // track(identifier: .itemFavorite)
    }

    func unfavorite() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            return
        }

        source.unfavorite(item: savedItem)
        // track(identifier: .itemUnfavorite)
    }

    func openInWebView(url: URL?) {
        let updatedURL = pocketPremiumURL(url, user: user)
        presentedWebReaderURL = updatedURL

        trackWebViewOpen()
    }

    func openExternalLink(url: URL) {
        let updatedURL = pocketPremiumURL(url, user: user)
        presentedWebReaderURL = updatedURL

        // trackExternalLinkOpen(url: url)
    }

    func moveFromArchiveToSaves(completion: (Bool) -> Void) {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            Log.capture(message: "Could not get SavedItem so unarchive action not taken")
            completion(false)
            return
        }
        source.unarchive(item: savedItem)
        trackMoveFromArchiveToSavesButtonTapped(url: savedItem.url)
        completion(true)
    }

    func archive() {
        guard let savedItem = sharedWithYouHighlight.item.savedItem else {
            Log.capture(message: "Could not get SavedItem so archive action not taken")
            return
        }

        source.archive(item: savedItem)
        trackArchiveButtonTapped(url: savedItem.url)
        _events.send(.archive)
    }

    func beginBulkEdit() {
    }

    private func save() {
        source.save(sharedWithYouHighlight: sharedWithYouHighlight)
        // track(identifier: .itemSave)
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

extension SharedWithYouHighlightViewModel {
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

extension SharedWithYouHighlightViewModel {
    func openInWebView(url: String) {
    }

    func save(completion: (Bool) -> Void) {
    }

    func trackReadingProgress(index: IndexPath) {
    }

    func readingProgress() -> IndexPath? {
        return nil
    }

    func listen() {
    }
}
