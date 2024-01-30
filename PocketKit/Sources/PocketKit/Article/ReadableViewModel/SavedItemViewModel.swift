// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import DiffMatchPatch
import Textile
import Analytics
import UIKit
import SharedPocketKit
import Localization

class SavedItemViewModel: ReadableViewModel, ObservableObject {
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

    @Published private(set) var isPresentingHighlights = false

    @Published private(set) var highlightIndexPath: IndexPath?

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
        if let highlights, !highlights.isEmpty, featureFlagService.isAssigned(flag: .marticleHighlights) {
            _actions.insert(highlightsAction(), at: 2)
        }
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

    private func highlightsAction() -> ItemAction {
        .showHighlights { [weak self] _ in
            self?.isPresentingHighlights = true
        }
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

// MARK: Highlights
extension SavedItemViewModel {
    var components: [ArticleComponent]? {
        guard featureFlagService.isAssigned(flag: .marticleHighlights),
              let highlights,
              !highlights.isEmpty else {
            return item.item?.article?.components
        }
        let patches = highlights.map { $0.patch }
        return item.item?.article?.components.highlighted(patches)
    }

    /// Array of fetched highlights, sorted by patch index
    var highlights: [Highlight]? {
        guard let highlights = item.highlights?.array as? [Highlight], !highlights.isEmpty else {
            return nil
        }
        return highlights.sorted {
            guard let firstIndex = textIndex(patch: $0.patch),
                  let secondIndex = textIndex(patch: $1.patch) else {
                // if there's no comparison to be made, just keep the existing order
                return false
            }
            return firstIndex < secondIndex
        }
    }

    func saveHighlight(componentIndex: Int, range: NSRange) {
        // find the component to be highlighted, without patches
        guard let component = item.item?.article?.components[safe: componentIndex],
              let content = getContent(from: component),
              // find the range to highlight
              let stringRange = Range(range, in: content),
              // get the previously patched component/content
              let previousComponent = components?[safe: componentIndex],
              let previousContent = getContent(from: previousComponent) else {
            Log.capture(message: "Unable to find a substring to highlight")
            return
        }

        let highlightString = content[stringRange]

        // merge the new patch with the new patch
        guard let mergedContent = mergeHighlights(
            previousContent,
            unpatchedContent: content,
            highlighableString: String(highlightString),
            range: stringRange
        ) else {
            Log.capture(message: "Unable to merge new patch into existing component")
            return
        }
        let updatedComponent = replaceContent(mergedContent, in: previousComponent)
        guard let previousComponents = components else {
            Log.capture(message: "Unable to construct the blob to patch")
            return
        }

        var newComponents = previousComponents
        guard newComponents.count > componentIndex else {
            Log.capture(message: "Invalid blob to patch")
            return
        }

        newComponents[componentIndex] = updatedComponent

        let previousBlob = previousComponents.rawText
        let newBlob = newComponents.rawText

        let diffMatchPatch = DiffMatchPatch()
        guard let patch = diffMatchPatch.patch_make(fromOldString: previousBlob, andNewString: newBlob).firstObject as? Patch else {
            Log.capture(message: "Unable to evaluate new patch")
            return
        }
        print(patch)
    }

    func deleteHighlight(_ ID: String) {
        guard let highlight = (highlights?.first { $0.remoteID == ID }) else {
            return
        }

        source.deleteHighlight(highlight: highlight)
        _events.send(.contentUpdated)
    }
}

// MARK: Highlights helpers
extension SavedItemViewModel {
    /// Extract the first text index from a patch
    /// - Parameter patch: the patch
    /// - Returns: the text index as Integer, if it was found, or nil
    private func textIndex(patch: String) -> Int? {
        guard let regex = try? Regex("@@[ \t]-([0-9]+),"),
                let match = patch.firstMatch(of: regex),
              // we want the match to capture the value
              match.count > 1,
              // and we want the capture to contain a valid string
              let matchedString = match[1].substring else {
            return nil
        }
        // return the integer value, if the string contains a valid number, or nil
        return Int(matchedString)
    }

    func shareHighlight(_ quote: String) {
        sharedActivity = PocketItemActivity.fromReader(url: url, additionalText: quote)
    }

    func scrollToIndexPath(_ indexPath: IndexPath) {
        highlightIndexPath = indexPath
    }

    /// Extracts the markdown portion (if it exists)  from an `ArticleComponent`
    /// - Parameter component: the component to parse
    /// - Returns: the markdown, if it exists, or nil
    private func getContent(from component: ArticleComponent) -> String? {
        switch component {
        case .blockquote(let blockQuote):
            return blockQuote.content
        case .codeBlock(let codeBlock):
            return codeBlock.content
        case .bulletedList(let bulletList):
            return bulletList.content
        case .heading(let heading):
            return heading.content
        case .image(let image):
            return image.content
        case .numberedList(let numberedList):
            return numberedList.content
        case .text(let text):
            return text.content
        default:
            return nil
        }
    }

    /// Merge the proposed highlight into a previously patched content (that is: content that could already contain highlights)
    /// - Parameters:
    ///   - previousContent: the previous content
    ///   - unpatchedContent: same as above, but without any patch
    ///   - highlightString: the substring to be highlighted
    /// - Returns: the merged contents
    private func mergeHighlights(_ previousContent: String, unpatchedContent: String, highlighableString: String, range: Range<String.Index>) -> String? {
        let ranges = unpatchedContent.ranges(of: highlighableString)
        // Find the match in the unpatched string, which is what comes from the textview
        let highlightableRange = ranges.enumerated().filter { $0.element == range }
        guard let higlightableIndex = highlightableRange.first?.offset else {
            return nil
        }
        // then find the same match in the already patched string (component)
        let patchedRanges = previousContent.ranges(of: highlighableString)
        guard let highlightablePatchedRange = patchedRanges[safe: higlightableIndex] else {
            return nil
        }
        var newContent = previousContent
        newContent.replaceSubrange(highlightablePatchedRange, with: "<pkt_tag_annotation>" + highlighableString + "</pkt_tag_annotation>")
        return newContent
    }

    private func replaceContent(_ content: String, in component: ArticleComponent) -> ArticleComponent {
        switch component {
        case .text:
            return .text(TextComponent(content: content))
        case .image(let imageComponent):
            var caption: String?
            var credit: String?
            if let originalCaption = imageComponent.caption, !originalCaption.isEmpty, let originalCredit = imageComponent.credit, !originalCredit.isEmpty, content.contains("[-]") {
                let captionComponents = content.components(separatedBy: "[-]")
                if captionComponents.count == 2 {
                    caption = captionComponents[0]
                    credit = captionComponents[1]
                }
            } else if let originalCaption = imageComponent.caption, imageComponent.credit == nil || imageComponent.credit?.isEmpty == true {
                caption = originalCaption.isEmpty ? originalCaption : content
            } else if imageComponent.caption == nil || imageComponent.caption?.isEmpty == true, let originalCredit = imageComponent.credit {
                credit = originalCredit.isEmpty ? originalCredit : content
            }
            return .image(
                    ImageComponent(
                        caption: caption,
                        credit: credit,
                        height: imageComponent.height,
                        width: imageComponent.width,
                        id: imageComponent.id,
                        source: imageComponent.source
                    )
                )
        case .heading(let headingComponent):
            return .heading(HeadingComponent(content: content, level: headingComponent.level))
        case .codeBlock(let codeBlockComponent):
            return .codeBlock(CodeBlockComponent(language: codeBlockComponent.language, text: content))
        case .bulletedList(let bulletedListComponent):
            let levels = bulletedListComponent.rows.map { $0.level }
            let rows = content.components(separatedBy: "\n").enumerated().map { row in
                BulletedListComponent.Row(content: row.element, level: UInt(levels[Swift.min(row.offset, levels.count - 1)]))
            }
            return .bulletedList(BulletedListComponent(rows: rows))
        case .numberedList(let numberedListComponent):
            let levels = numberedListComponent.rows.map { $0.level }
            let indexes = numberedListComponent.rows.map { $0.index }
            let rows = content.components(separatedBy: "\n").enumerated().map { row in
                NumberedListComponent.Row(content: row.element, level: UInt(levels[row.offset]), index: UInt(indexes[row.offset]))
            }
            return .numberedList(NumberedListComponent(rows: rows))
        case .blockquote:
            return .blockquote(BlockquoteComponent(content: content))
        case .unsupported, .video, .table, .divider:
            return component
        }
    }
}
