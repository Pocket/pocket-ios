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
import Network
import SwiftUI

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

    @Published private(set) var isPresentingPremiumUpsell = false

    @Published private(set) var isPresentingHooray = false

    @Published var highlightedQuotes = [HighlightedQuote]()

    private var _dismissReason: DismissReason = .swipe {
        willSet {
            if newValue == .system {
                isPresentingHooray = true
            }
        }
    }

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

        if let url = item.item?.sharetURL {
            self.shareUrl = url
        } else if let item = item.item {
            Task {
                // TODO: add shareUrl retrieval here
                // self.shortUrl = try? await source.getItemShortUrl(item.givenURL)
            }
        }
    }

    lazy var dismissReason: Binding<DismissReason> = {
        .init(get: {
            self._dismissReason
        }, set: { reason in
            self._dismissReason = reason
        })
    }()

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

    var shareUrl: String?

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
        if let highlights, !highlights.isEmpty {
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
            self?.tracker.track(event: Events.ReaderToolbar.viewHighlights())
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
        guard let highlights,
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

    var canAddHighlight: Bool {
        (highlights?.count ?? 0) < 3 || Services.shared.user.status == .premium
    }

    func saveHighlight(componentIndex: Int, range: NSRange, quote: String, text: String) {
        guard canAddHighlight else {
            isPresentingPremiumUpsell = true
            return
        }
        // find the component to be highlighted, without patches
        guard let component = item.item?.article?.components[safe: componentIndex],
              let content = getContent(from: component),
              // find the range to highlight
              let stringRange = Range(range, in: text),
              // get the previously patched component/content
              let previousComponent = components?[safe: componentIndex],
              let previousContent = getContent(from: previousComponent) else {
            Log.capture(message: "Unable to find a substring to highlight")
            return
        }

        // merge the new patch with the component
        guard let mergedContent = mergeHighlights(
            previousContent,
            unpatchedContent: content,
            quote: quote,
            range: stringRange,
            rawText: text
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
        guard let patch = diffMatchPatch.patch_make(fromOldString: previousBlob, andNewString: newBlob),
                let textPatch = diffMatchPatch.patch_(toText: patch) else {
            Log.capture(message: "Unable to evaluate new patch")
            return
        }
        source.addHighlight(itemIID: item.objectID, patch: textPatch, quote: quote)
        _events.send(.contentUpdated)
        tracker.track(event: Events.Reader.addHighlight())
    }

    func deleteHighlight(_ ID: String) {
        guard let highlight = (highlights?.first { $0.remoteID == ID }) else {
            return
        }

        source.deleteHighlight(highlight: highlight)
        _events.send(.contentUpdated)
        tracker.track(event: Events.Reader.removeHighlight())
    }

    func shareHighlight(_ quote: String) {
        sharedActivity = PocketItemActivity.fromReader(url: url, additionalText: quote)
        tracker.track(event: Events.Reader.shareHighlight())
    }

    func scrollToIndexPath(_ indexPath: IndexPath) {
        highlightIndexPath = indexPath
    }
}

// MARK: Highlights helpers
private extension SavedItemViewModel {
    /// Extract the first text index from a patch
    /// - Parameter patch: the patch
    /// - Returns: the text index as Integer, if it was found, or nil
    func textIndex(patch: String) -> Int? {
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

    /// Extracts the markdown portion (if it exists)  from an `ArticleComponent`
    /// - Parameter component: the component to parse
    /// - Returns: the markdown, if it exists, or nil
    func getContent(from component: ArticleComponent) -> String? {
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

    /// Merge the proposed highlight into a previously patched content (that is: content that could already contain highlights), in the current component
    /// - Parameters:
    ///   - previousContent: the previous content
    ///   - unpatchedContent: same as above, but without any patch
    ///   - highlightString: the substring to be highlighted
    ///   - quote: the original quote to be highlighted, extracted from the text that users see in the article
    ///   - range: the range of the original quote
    ///   - rawText: the original text  that users see in the article
    /// - Returns: the merged contents
    func mergeHighlights(
        _ previousContent: String,
        unpatchedContent: String,
        quote: String,
        range: Range<String.Index>,
        rawText: String
    ) -> String? {
        // make sure we are using the right quote in the right text
        guard rawText[range] == quote else {
            Log.capture(message: "Unable to apply highlight: match not found in component markdown - step 1")
            return nil
        }
        // if we can't patch with the default DiffMatchPatch parameters, attempt to broaden the search
        // if we do not find a valid patch with the broader search, we then give up.
        return patchRawText(
            rawText: rawText,
            quote: quote,
            previousContent: previousContent,
            range: range
        )

        ??

        patchRawText(
            rawText: rawText,
            quote: quote,
            previousContent: previousContent,
            range: range,
            diffMatchPatchDistance: 3000,
            diffMatchPatchThreshold: 0.8
        )
    }

    func patchRawText(
        rawText: String,
        quote: String,
        previousContent: String,
        range: Range<String.Index>,
        diffMatchPatchDistance: Int = 1000,
        diffMatchPatchThreshold: Double = 0.5
    ) -> String? {
        var patchedRawText = rawText
        let initialStartTagsCount = countStartTags(in: previousContent)
        let initialEndTagsCount = countEndTags(in: previousContent)
        patchedRawText.replaceSubrange(range, with: "<pkt_tag_annotation>" + quote + "</pkt_tag_annotation>")
        let diffMatchPatch = DiffMatchPatch()
        diffMatchPatch.match_Distance = diffMatchPatchDistance
        diffMatchPatch.match_Threshold = diffMatchPatchThreshold
        guard let patch = diffMatchPatch.patch_make(fromOldString: rawText, andNewString: patchedRawText) as? [Patch] else {
            Log.capture(message: "Unable to apply highlight: match not found in component markdown - step 2")
            return nil
        }
        let patched = diffMatchPatch.patch_apply(patch, to: previousContent)
        guard let patchedMarkdown = patched?.first as? String else {
            Log.capture(message: "Unable to apply highlight: match not found in component markdown - step 3")
            return nil
        }
        let startTagsCount = countStartTags(in: patchedMarkdown)
        let endTagsCount = countEndTags(in: patchedMarkdown)
        // ensure that the tags were properly inserted and that the start and end tags match
        guard startTagsCount == initialStartTagsCount + 1, endTagsCount == initialEndTagsCount + 1, startTagsCount == endTagsCount else {
            Log.capture(message: "Unable to apply highlight: match not found in component markdown - step 4")
            return nil
        }
        return patchedMarkdown
    }

    func countStartTags(in markdown: String) -> Int {
        markdown.components(separatedBy: "<pkt_tag_annotation").count - 1
    }

    func countEndTags(in markdown: String) -> Int {
        markdown.components(separatedBy: "</pkt_tag_annotation>").count - 1
    }

    func replaceContent(_ content: String, in component: ArticleComponent) -> ArticleComponent {
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
            let updatedContent = normalizeHeadingIfNeeded(content, level: Int(headingComponent.level))
            return .heading(HeadingComponent(content: updatedContent, level: headingComponent.level))
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

    /// Some heading components could be patched in a way that the start annotation tag is positioned right before the heading markdown tag.
    /// If this happens, `Down` would not interpret the markdown correctly, resulting in wrong format displayed.
    /// To fix this, we move the start annotation tag right after the markdown indicator.
    func normalizeHeadingIfNeeded(_ content: String, level: Int) -> String {
        let tag = "<pkt_tag_annotation>"
        guard content.contains(tag + "#") else {
            return content
        }
        let partialContent = content.replacingOccurrences(of: tag, with: "")
        let header = String(repeating: "#", count: level) + " "
        let normalizedContent = partialContent.replacingOccurrences(of: header, with: header + tag)
        return normalizedContent
    }
}

// MARK: Premium upsell
extension SavedItemViewModel {
    func makePremiumViewModel() -> PremiumUpgradeViewModel {
        PremiumUpgradeViewModel(store: Services.shared.subscriptionStore, tracker: tracker, source: .highlights, networkPathMonitor: NWPathMonitor())
    }

    func makePremiumUpgradeViewController() -> UIViewController {
        defer {
            tracker.track(event: Events.Reader.highlightUpsellViewed())
        }
        let viewModel = makePremiumViewModel()
        return UIHostingController(rootView: PremiumUpgradeView(dismissReason: dismissReason, viewModel: viewModel))
    }

    func makeHoorayViewController() -> UIViewController {
        UIHostingController(rootView: PremiumUpgradeSuccessView())
    }
}
