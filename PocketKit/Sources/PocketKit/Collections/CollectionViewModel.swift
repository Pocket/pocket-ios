// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit
import SharedPocketKit
import Combine
import CoreData
import Localization
import Analytics

/// View model that holds logic for the native collection view
class CollectionViewModel: NSObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot

    @Published var presentedAlert: PocketAlert?
    @Published var presentedAddTags: PocketAddTagsViewModel?
    @Published var sharedActivity: PocketActivity?
    @Published var selectedCollectionItemToReport: Item?

    @Published var selectedItem: ReadableType?
    @Published var presentedStoryWebReaderURL: URL?

    @Published var sharedStoryActivity: PocketActivity?
    @Published var selectedStoryToReport: Item?

    @Published private(set) var _events: ReadableEvent?
    var events: Published<ReadableEvent?>.Publisher { $_events }

    @Published private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private let collection: Collection
    private let source: Source
    private let tracker: Tracker
    private let user: User
    private let store: SubscriptionStore
    private let networkPathMonitor: NetworkPathMonitor
    private let userDefaults: UserDefaults
    private let featureFlags: FeatureFlagServiceProtocol
    private let notificationCenter: NotificationCenter

    private let collectionController: RichFetchedResultsController<CollectionStory>

    private var url: String
    private var collectionItemSubscriptions: Set<AnyCancellable> = []

    init(
        collection: Collection,
        source: Source,
        tracker: Tracker,
        user: User,
        store: SubscriptionStore,
        networkPathMonitor: NetworkPathMonitor,
        userDefaults: UserDefaults,
        featureFlags: FeatureFlagServiceProtocol,
        notificationCenter: NotificationCenter
    ) {
        self.collection = collection
        self.source = source
        self.tracker = tracker
        self.user = user
        self.store = store
        self.networkPathMonitor = networkPathMonitor
        self.userDefaults = userDefaults
        self.featureFlags = featureFlags
        self.notificationCenter = notificationCenter

        self.collectionController = source.makeCollectionStoriesController(slug: collection.slug)

        self.snapshot = Self.loadingSnapshot()
        self.url = "https://getpocket.com/collections/\(collection.slug)"
        super.init()
        collectionController.delegate = self
        buildActions()

        item?.publisher(for: \.savedItem?.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)

        item?.publisher(for: \.savedItem).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)

        trackScreenView()
    }

    var title: String {
        collection.title ?? ""
    }

    var authors: [String] {
        ((collection.authors?.compactMap { $0 as? CollectionAuthor }) ?? [CollectionAuthor]()).map { $0.name }
    }

    var storiesCount: Int? {
        collectionController.fetchedObjects?.count
    }

    var intro: Markdown? {
        collection.intro
    }

    var item: Item? {
        return collection.item
    }

    var isArchived: Bool? {
        guard let item else { return nil }
        return item.savedItem?.isArchived
    }

    func fetch() {
        do {
            try collectionController.performFetch()
        } catch {
            // TODO: NATIVECOLLECTIONS - handle core data error here
        }
        Task {
            do {
                try await source.fetchCollection(by: collection.slug)
            } catch {
                Log.capture(message: "Failed to fetch details for CollectionViewModel: \(error)")
                // TODO: NATIVECOLLECTIONS - handle remote error here
            }
        }
    }

    func archive() {
        trackArchiveButtonTapped()
        guard let savedItem = item?.savedItem else {
            Log.capture(message: "Failed to archive item due to savedItem being nil")
            return
        }

        source.archive(item: savedItem)
        _events = .archive
    }

    // If savedItem exists, then unarchive the item to appear in Saves, otherwise save the item
    func moveToSaves(completion: (Bool) -> Void) {
        guard let savedItem = item?.savedItem else {
            trackSave()
            source.save(url: url)
            completion(true)
            return
        }
        trackMoveFromArchiveToSavesButtonTapped()
        source.unarchive(item: savedItem)
        completion(true)
    }

    private func buildActions() {
        guard let savedItem = item?.savedItem else {
            _actions = [
                .share { [weak self] _ in self?.share() },
                .report { [weak self] _ in self?.report() }
            ]
            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite(savedItem) }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite(savedItem) }
        }

        _actions = [
            favoriteAction,
            tagsAction(for: savedItem),
            .delete { [weak self] _ in self?.confirmDelete(for: savedItem) },
            .share { [weak self] _ in self?.share() }
        ]
    }

    private func tagsAction(for item: SavedItem) -> ItemAction {
        let hasTags = (item.tags?.count ?? 0) > 0
        if hasTags {
            return .editTags { [weak self] _ in self?.showAddTagsView(for: item) }
        } else {
            return .addTags { [weak self] _ in self?.showAddTagsView(for: item) }
        }
    }

    private func showAddTagsView(for item: SavedItem) {
        trackAddTags()
        presentedAddTags = PocketAddTagsViewModel(
            item: item,
            source: source,
            tracker: tracker,
            userDefaults: userDefaults,
            user: user,
            store: store,
            networkPathMonitor: networkPathMonitor,
            saveAction: { }
        )
    }

    private func favorite(_ savedItem: SavedItem) {
        trackFavorite()
        source.favorite(item: savedItem)
    }

    private func unfavorite(_ savedItem: SavedItem) {
        trackUnfavorite()
        source.unfavorite(item: savedItem)
    }

    private func confirmDelete(for savedItem: SavedItem) {
        trackDelete()
        presentedAlert = PocketAlert(
            title: Localization.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: Localization.yes, style: .destructive) { [weak self] _ in self?.delete(savedItem) },
            ],
            preferredAction: nil
        )
    }

    private func delete(_ savedItem: SavedItem) {
        presentedAlert = nil
        source.delete(item: savedItem)
        _events = .delete
    }

    private func share(additionalText: String? = nil) {
        trackShare()
        sharedActivity = PocketItemActivity.fromCollection(url: url, additionalText: additionalText)
    }

    private func report() {
        trackReport()
        selectedCollectionItemToReport = item
    }
}

// MARK: - Cell Selection
extension CollectionViewModel {
    func storyViewModel(for story: CollectionStory) -> CollectionStoryViewModel {
        return CollectionStoryViewModel(
            collectionStory: story,
            source: source,
            tracker: tracker,
            overflowActions: [
                .share { [weak self] sender in
                    self?.trackStoryShare(storyURL: story.url)
                    self?.sharedStoryActivity = PocketItemActivity.fromCollection(url: story.url, sender: sender)
                },
                .report { [weak self] _ in
                    self?.trackStoryReport(storyURL: story.url)
                    self?.selectedStoryToReport = story.item
                }
            ]
        )
    }

    func select(cell: CollectionViewModel.Cell) {
        switch cell {
        case .loading, .collectionHeader:
            return
        case .story(let storyViewModel):
            trackContentOpen(storyURL: storyViewModel.collectionStory.url)
            selectItem(with: storyViewModel.collectionStory)
        }
    }

    private func selectItem(with story: CollectionStory) {
        // Check if item is a collection
        if let collection = story.item?.collection, featureFlags.isAssigned(flag: .nativeCollections) {
            selectedItem = .collection(
                CollectionViewModel(collection: collection, source: source, tracker: tracker, user: user, store: store, networkPathMonitor: networkPathMonitor, userDefaults: userDefaults, featureFlags: featureFlags, notificationCenter: notificationCenter)
                )
        // Check if item is a saved item
        } else if let item = story.item, !item.shouldOpenInWebView(override: featureFlags.shouldDisableReader), let savedItem = item.savedItem {
            selectedItem = .savedItem(
                SavedItemViewModel(
                    item: savedItem,
                    source: source,
                    tracker: tracker.childTracker(hosting: .articleView.screen),
                    pasteboard: UIPasteboard.general,
                    user: user,
                    store: store,
                    networkPathMonitor: networkPathMonitor,
                    userDefaults: userDefaults,
                    notificationCenter: notificationCenter
                )
            )
        // Check if item has an associated recommendation
        } else if let item = story.item, !item.shouldOpenInWebView(override: featureFlags.shouldDisableReader), let recommendation = item.recommendation {
            selectedItem = .recommendation(
                RecommendationViewModel(
                    recommendation: recommendation,
                    source: source,
                    tracker: tracker,
                    pasteboard: UIPasteboard.general,
                    user: user,
                    userDefaults: userDefaults
                )
            )
        // Else open item in webview
        } else {
            guard let bestURL = URL(percentEncoding: story.url) else { return }
            let url = pocketPremiumURL(bestURL, user: user)
            presentedStoryWebReaderURL = url
        }
    }
}

private extension CollectionViewModel {
    static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
    }

    /// Builds and sets snapshot when collection stories are found in Core Data
    func setCollectionSnapshot(_ identifiers: [NSManagedObjectID]) {
        var collectionSnapshot = Snapshot()
        let storiesSection = Section.collection(collection)
        collectionSnapshot.appendSections([.collectionHeader, storiesSection])
        collectionSnapshot.appendItems([.collectionHeader], toSection: .collectionHeader)

        let cells = buildStoryCells(from: identifiers)
        collectionSnapshot.appendItems(cells, toSection: storiesSection)
        self.snapshot = collectionSnapshot
    }

    /// Reloads and/or reconfigures items in the existing snapshot
    func updateCollectionSnapshot(_ reloadableIdentifiers: [NSManagedObjectID], reconfigurableIdentifiers: [NSManagedObjectID]) {
        var updatedSnapshot = self.snapshot

        let reloadableCells = buildStoryCells(from: reloadableIdentifiers)
        let reconfigurableCells = buildStoryCells(from: reconfigurableIdentifiers)

        updatedSnapshot.reloadItems(reloadableCells)
        updatedSnapshot.reconfigureItems(reconfigurableCells)
        self.snapshot = updatedSnapshot
    }

    func buildStoryCells( from identifiers: [NSManagedObjectID]) -> [Cell] {
        let collectionStories: [CollectionStory] = identifiers.compactMap {
            source.viewObject(id: $0) as? CollectionStory
        }

        let cells = collectionStories.map {
            Cell.story(storyViewModel(for: $0))
        }
        return cells
    }

    func convertToManagedObjectIds(_ identifiers: [Any]) -> [NSManagedObjectID] {
        identifiers.compactMap { $0 as? NSManagedObjectID }
    }
}

extension CollectionViewModel {
    enum Section: Hashable {
        case loading
        case collectionHeader
        case collection(Collection)
    }

    enum Cell: Hashable {
        case loading
        case collectionHeader
        case story(CollectionStoryViewModel)
    }
}

extension CollectionViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard !snapshot.itemIdentifiers.isEmpty else {
            return
        }
        if snapshot.reloadedItemIdentifiers.isEmpty && snapshot.reconfiguredItemIdentifiers.isEmpty {
            setCollectionSnapshot(convertToManagedObjectIds(snapshot.itemIdentifiers))
        } else {
            updateCollectionSnapshot(
                convertToManagedObjectIds(snapshot.reloadedItemIdentifiers),
                reconfigurableIdentifiers: convertToManagedObjectIds(snapshot.reconfiguredItemIdentifiers)
            )
        }
    }
}

// MARK: - Analytics
extension CollectionViewModel {
    /// track native collection view
    func trackScreenView() {
        tracker.track(event: Events.Collection.screenView())
    }

    /// track save button tapped in collection toolbar
    func trackSave() {
        tracker.track(event: Events.Collection.saveClicked(url: url))
    }

    /// track archive button tapped in collection toolbar
    func trackArchiveButtonTapped() {
        tracker.track(event: Events.Collection.unsaveClicked(url: url))
    }

    /// track move to saves from archive button tapped in collection toolbar
    func trackMoveFromArchiveToSavesButtonTapped() {
        tracker.track(event: Events.Collection.moveFromArchiveToSavesClicked(url: url))
    }

    /// track overflow menu tapped in collection toolbar
    func trackOverflow() {
        tracker.track(event: Events.Collection.overflowClicked(url: url))
    }

    /// track favorite button tapped in collection toolbar overflow menu
    func trackFavorite() {
        tracker.track(event: Events.Collection.favoriteClicked(url: url))
    }

    /// track unfavorite button tapped in collection toolbar overflow menu
    func trackUnfavorite() {
        tracker.track(event: Events.Collection.unfavoriteClicked(url: url))
    }

    /// track add tags button tapped in collection toolbar overflow menu
    func trackAddTags() {
        tracker.track(event: Events.Collection.addTagsClicked(url: url))
    }

    /// track delete button tapped in collection toolbar overflow menu
    func trackDelete() {
        tracker.track(event: Events.Collection.deleteClicked(url: url))
    }

    /// track share button tapped in collection toolbar overflow menu
    func trackShare() {
        tracker.track(event: Events.Collection.shareClicked(url: url))
    }

    /// track report button tapped in collection toolbar overflow menu
    func trackReport() {
        tracker.track(event: Events.Collection.reportClicked(url: url))
    }

    /// track user opening a story
    func trackContentOpen(storyURL: String) {
        tracker.track(event: Events.Collection.contentOpen(url: storyURL))
    }

    /// track share button tapped in collection toolbar overflow menu
    func trackStoryShare(storyURL: String) {
        tracker.track(event: Events.Collection.storyShareClicked(url: storyURL))
    }

    /// track report button tapped in collection toolbar overflow menu
    func trackStoryReport(storyURL: String) {
        tracker.track(event: Events.Collection.storyReportClicked(url: storyURL))
    }
}
