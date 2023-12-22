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
import DiffMatchPatch

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

    private func readingProgressKeyBase(url: String) -> String {
        "readingProgress.\(url)."
    }

    weak var delegate: ReadableViewModelDelegate?

    let readableSource: ReadableSource

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
    private let featureFlagService: FeatureFlagServiceProtocol

    init(
        item: SavedItem,
        source: Source,
        tracker: Tracker,
        pasteboard: Pasteboard,
        user: User,
        store: SubscriptionStore,
        networkPathMonitor: NetworkPathMonitor,
        userDefaults: UserDefaults,
        notificationCenter: NotificationCenter,
        readableSource: ReadableSource = .app,
        featureFlagService: FeatureFlagServiceProtocol
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
        self.readableSource = readableSource
        self.featureFlagService = featureFlagService

        item.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)

        item.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)
    }

    lazy var readerSettings: ReaderSettings = {
        ReaderSettings(tracker: tracker, userDefaults: userDefaults)
    }()

    var components: [ArticleComponent]? {
        patchArticle()
    }

    var highlightableComponents: [Highlightable] {
        guard let originalComponents = item.item?.article?.components else {
            return []
        }
        return originalComponents.compactMap { component in
            if case let .text(textComponent) = component {
                return textComponent
            }
            if case let .blockquote(blockquoteComponent) = component {
                return blockquoteComponent
            }
            if case let .bulletedList(bulletedListComponent) = component {
                return bulletedListComponent
            }
            if case let .codeBlock(codeBlockComponent) = component {
                return codeBlockComponent
            }
            if case let .heading(headingComponent) = component {
                return headingComponent
            }
            if case let .numberedList(numberedListComponent) = component {
                return numberedListComponent
            }
            return nil
        }
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
        item.displayDomain
    }

    var publishDate: Date? {
        item.item?.datePublished
    }

    var url: String {
        item.bestURL
    }

    var itemSaveStatus: ItemSaveStatus {
        if item.isArchived {
            return .archived
        }
        return .saved
        // unsaved option is not applicable to this type since it needs a SavedItem
    }

    var isCollection: Bool {
        item.isCollection
    }

    var collection: Collection? {
        item.item?.collection
    }

    var slug: String? {
        item.item?.collectionSlug
    }

    var premiumURL: String? {
        pocketPremiumURL(url, user: user)
    }

    var isListenSupported: Bool {
        item.isEligibleForListen
    }

    static let componentSeparator = "<_pkt_>"

    var rawText: String {
        var blob = String()

        highlightableComponents.enumerated().forEach {
            blob.append($0.element.content)
            if $0.offset < highlightableComponents.count - 1 {
                blob.append(Self.componentSeparator)
            }
        }
        return blob
    }

    /// Evaluates the patches that represent highlights on the entire artticle text
    func patchArticle() -> [ArticleComponent]? {
        guard let highlights = item.highlights?.array as? [Highlight], !rawText.isEmpty else {
            return item.item?.article?.components
        }
        let patches = highlights.map { $0.patch }
        let diffMatchPatch = DiffMatchPatch()
        // TODO: these are pretty broad parameters that seem to work in many common cases. We might need to tweak these and use an iterative approach for faster performance.
        diffMatchPatch.match_Distance = 3000
        diffMatchPatch.match_Threshold = 0.65
        let totalPatches = patches.reduce(into: [Patch]()) {
            if let patches = try? diffMatchPatch.patch_(fromText: $1) as? [Patch] {
                $0.append(contentsOf: patches)
            }
        }
        guard let patchedResult = diffMatchPatch.patch_apply(totalPatches, to: rawText)?.first as? String else {
            Log.capture(message: "Unable to patch article")
            return item.item?.article?.components
        }
        do {
            let normalizedComponents = try normalizedComponents(patchedResult)
            return mergedComponents(normalizedComponents) ?? item.item?.article?.components
        } catch {
            Log.capture(error: error)
            return item.item?.article?.components
        }
    }

    func mergedComponents(_ patchedComponents: [String]) -> [ArticleComponent]? {
        guard let components = item.item?.article?.components,
                components.count >= patchedComponents.count,
                !patchedComponents.isEmpty else {
            return nil
        }
        var mergedComponents = [ArticleComponent]()
        var patchedIndex = 0

        components.forEach {
            if let content = patchedComponents[safe: patchedIndex] {
                switch $0 {
                case .text:
                    mergedComponents.append(.text(TextComponent(content: content)))
                    patchedIndex += 1
                case .heading(let headingComponent):
                    mergedComponents.append(.heading(HeadingComponent(content: content, level: headingComponent.level)))
                    patchedIndex += 1
                case .codeBlock(let codeBlockComponent):
                    mergedComponents.append(.codeBlock(CodeBlockComponent(language: codeBlockComponent.language, text: content)))
                    patchedIndex += 1
                case .bulletedList(let bulletedListComponent):
                    let levels = bulletedListComponent.rows.map { $0.level }
                    let rows = content.components(separatedBy: "\n").enumerated().map { row in
                        BulletedListComponent.Row(content: row.element, level: UInt(levels[row.offset]))
                    }
                    mergedComponents.append(.bulletedList(BulletedListComponent(rows: rows)))
                    patchedIndex += 1
                case .numberedList(let numberedListComponent):
                    let levels = numberedListComponent.rows.map { $0.level }
                    let indexes = numberedListComponent.rows.map { $0.index }
                    let rows = content.components(separatedBy: "\n").enumerated().map { row in
                        NumberedListComponent.Row(content: row.element, level: UInt(levels[row.offset]), index: UInt(indexes[row.offset]))
                    }
                    mergedComponents.append(.numberedList(NumberedListComponent(rows: rows)))
                    patchedIndex += 1
                case .blockquote:
                    mergedComponents.append(.blockquote(BlockquoteComponent(content: content)))
                    patchedIndex += 1
                default:
                    mergedComponents.append($0)
                }
            }
        }
        return mergedComponents
    }

    func normalizedComponents(_ patchedBlob: String) throws -> [String] {
        var patchedComponents = patchedBlob.components(separatedBy: Self.componentSeparator)

        let scanner = Scanner(string: patchedBlob)
        var componentCursor = 0
        var tagStack = [String]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString("pkt_") != nil else {
                return patchedComponents
            }
            let beforeIndex = max(patchedBlob.index(before: scanner.currentIndex), patchedBlob.startIndex)
            let character = String(patchedBlob[beforeIndex])
            if character == "<" {
                tagStack.append("<pkt_tag_annotation>")
            }
            if character == "/" {
                guard !tagStack.isEmpty else {
                    // in the entire blob, we are not supposed to find a closing tag without an opening tag
                    throw HighlightError.invalidPatch(componentCursor)
                }
                tagStack.removeLast()
            }
            if character == "_" {
                if !tagStack.isEmpty {
                    // no pending highlights, let's just move on
                    // continue

                    var currentComponent = patchedComponents[componentCursor]
                    var nextComponent = patchedComponents[componentCursor + 1]
                    tagStack.forEach {
                        currentComponent.insert(contentsOf: "</pkt_tag_annotation>", at: currentComponent.endIndex)
                        nextComponent.insert(contentsOf: $0, at: nextComponent.startIndex)
                    }
                    patchedComponents[componentCursor] = currentComponent
                    patchedComponents[componentCursor + 1] = nextComponent
                }
                componentCursor += 1
            }
            if !scanner.isAtEnd {
                scanner.currentIndex = patchedBlob.index(after: scanner.currentIndex)
            }
        }
        return patchedComponents
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

    func listen() {
        delegate?.viewModel(
            self,
            didRequestListen: ListenConfiguration(
                title: item.isArchived ? Localization.archive : "Saves",
                savedItems: [item],
                featureFlagService: featureFlagService
            )
        )
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

    func save(completion: (Bool) -> Void) {
        // NO-OP: this type is initialized with a valid SavedItem, which won't need to be saved.
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

enum HighlightError: Error {
    case noPatches
    case invalidPatch(Int)
}
