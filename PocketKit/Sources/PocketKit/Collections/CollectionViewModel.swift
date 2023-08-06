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
import Network

/// View model that holds logic for the native collection view
class CollectionViewModel: NSObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published private(set) var snapshot: Snapshot
    @Published private(set) var metadata: CollectionMetadata = .empty
    @Published private(set) var isArchived: Bool = false

    @Published private(set) var presentedAlert: PocketAlert?
    @Published private(set) var presentedAddTags: PocketAddTagsViewModel?
    @Published private(set) var sharedActivity: PocketActivity?

    @Published private(set) var selectedCollectionItemToReport: Item?
    @Published private(set) var selectedItem: ReadableType?
    @Published private(set) var presentedStoryWebReaderURL: URL?

    @Published private(set) var sharedStoryActivity: PocketActivity?
    @Published private(set) var selectedStoryToReport: Item?
    @Published private(set) var events: ReadableEvent?

    @Published private(set) var actions: [ItemAction] = []

    private var collection: Collection?
    private let source: Source
    private let tracker: Tracker
    private let user: User
    private let store: SubscriptionStore
    private let networkPathMonitor: NetworkPathMonitor
    private var currentNetworkStatus: NWPath.Status?
    private let userDefaults: UserDefaults
    private let featureFlags: FeatureFlagServiceProtocol
    private let notificationCenter: NotificationCenter

    private let collectionController: RichFetchedResultsController<CollectionStory>

    private let slug: String

    private let url: String
    private var collectionItemSubscriptions: Set<AnyCancellable> = []

    init(
        slug: String,
        source: Source,
        tracker: Tracker,
        user: User,
        store: SubscriptionStore,
        networkPathMonitor: NetworkPathMonitor,
        userDefaults: UserDefaults,
        featureFlags: FeatureFlagServiceProtocol,
        notificationCenter: NotificationCenter
    ) {
        self.slug = slug
        self.source = source
        self.tracker = tracker
        self.user = user
        self.store = store
        self.networkPathMonitor = networkPathMonitor
        self.userDefaults = userDefaults
        self.featureFlags = featureFlags
        self.notificationCenter = notificationCenter

        self.collectionController = source.makeCollectionStoriesController(slug: slug)

        self.snapshot = Self.loadingSnapshot()
        self.url = "https://getpocket.com/collections/\(slug)"
        super.init()
        collectionController.delegate = self
        trackScreenView()

        networkPathMonitor.start(queue: .global())
        currentNetworkStatus = networkPathMonitor.currentNetworkPath.status
        observeNetworkChanges()
    }

    /// Determines whether collection has local data based on stories count
    var hasLocalData: Bool {
        collectionController.fetchedObjects?.isEmpty == false
    }

    var item: Item? {
        return collection?.item
    }

    func fetch() {
        do {
            try collectionController.performFetch()
            guard !hasLocalData else {
                // if we have stories, no need to show error messages when we are offline
                networkPathMonitor.cancel()
                return
            }
            if isOffline {
                snapshot = self.errorSnapshot()
            } else {
                fetchRemoteCollection()
            }
        } catch {
            self.snapshot = errorSnapshot()
            Log.capture(message: "Failed to fetch details for CollectionViewModel: \(error)")
        }
    }

    func fetchRemoteCollection() {
        Task {
            do {
                try await source.fetchCollection(by: slug)
            } catch {
                self.snapshot = errorSnapshot()
                Log.capture(message: "Failed to fetch remote collection stories: \(error)")
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
        events = .archive
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
            actions = [
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

        actions = [
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
        events = .delete
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

// MARK: Error / Offline
extension CollectionViewModel {
    var errorEmptyState: EmptyStateViewModel {
        return ErrorEmptyState(featureFlags: featureFlags, user: user)
    }

    var isOffline: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    private func observeNetworkChanges() {
        networkPathMonitor.updateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handleNetworkChange(path.status)
            }
        }
    }

    /// Observes network changes and fetch collection when user returns online
    private func handleNetworkChange(_ status: NWPath.Status) {
        guard status != currentNetworkStatus else {
            return
        }

        if currentNetworkStatus == .unsatisfied, status == .satisfied {
            guard !hasLocalData else { return }
            self.snapshot = Self.loadingSnapshot()
            fetch()
        }
        currentNetworkStatus = status
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
        case .loading, .collectionHeader, .error:
            return
        case .story(let storyViewModel):
            trackContentOpen(storyURL: storyViewModel.collectionStory.url)
            selectItem(with: storyViewModel.collectionStory)
        }
    }

    private func selectItem(with story: CollectionStory) {
        // Check if item is a collection
        if let slug = story.item?.collectionSlug, featureFlags.isAssigned(flag: .nativeCollections) {
            selectedItem = .collection(
                CollectionViewModel(slug: slug, source: source, tracker: tracker, user: user, store: store, networkPathMonitor: networkPathMonitor, userDefaults: userDefaults, featureFlags: featureFlags, notificationCenter: notificationCenter)
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

    /// Builds snapshot for when user faces offline or error
    func errorSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.error])
        snapshot.appendItems([.error], toSection: .error)
        return snapshot
    }

    func listenForItemChanges() {
        item?.publisher(for: \.savedItem?.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)

        item?.publisher(for: \.savedItem?.isArchived).sink { [weak self] isArchived in
            self?.isArchived = isArchived ?? false
        }.store(in: &collectionItemSubscriptions)

        item?.publisher(for: \.savedItem).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)
    }

    /// Builds collections, metadata and stories when collection data are found in Core Data
    func buildCollection(_ identifiers: [NSManagedObjectID]) {
        guard let id = identifiers.first,
        let story = source.viewObject(id: id) as? CollectionStory,
            let collection = story.collection else {
            return
        }
        self.collection = collection
        isArchived = collection.item?.savedItem?.isArchived ?? false
        listenForItemChanges()
        buildActions()
        self.metadata = CollectionMetadata(
            title: collection.title ?? "",
            authors: ((collection.authors?.compactMap { $0 as? CollectionAuthor }) ?? [CollectionAuthor]()).map { $0.name },
            storiesCount: identifiers.count,
            intro: collection.intro
        )

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
        case error
    }

    enum Cell: Hashable {
        case loading
        case collectionHeader
        case story(CollectionStoryViewModel)
        case error
    }
}

extension CollectionViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard !snapshot.itemIdentifiers.isEmpty else {
            return
        }
        if snapshot.reloadedItemIdentifiers.isEmpty && snapshot.reconfiguredItemIdentifiers.isEmpty {
            buildCollection(convertToManagedObjectIds(snapshot.itemIdentifiers))
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
