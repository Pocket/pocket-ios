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

    @Published var snapshot: Snapshot

    @Published var presentedAlert: PocketAlert?
    @Published var presentedAddTags: PocketAddTagsViewModel?
    @Published var sharedActivity: PocketActivity?
    @Published var selectedCollectionItemToReport: Item?

    @Published var selectedReadableViewModel: ReadableViewModel?
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
    private var currentNetworkStatus: NWPath.Status?
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

        item?.savedItem?.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)

        networkPathMonitor.start(queue: .global())
        currentNetworkStatus = networkPathMonitor.currentNetworkPath.status
        observeNetworkChanges()
    }

    var hasLocalData: Bool {
        !title.isEmpty
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

        guard !isOffline else {
            checkForLocalData()
            return
        }

        Task {
            do {
                try await source.fetchCollection(by: collection.slug)
            } catch {
                // TODO: NATIVECOLLECTIONS - handle remote error here
                self.snapshot = errorSnapshot()
                Log.capture(message: "Failed to fetch details for CollectionViewModel: \(error)")
            }
        }
    }

    func archive() {
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
            source.save(url: url)
            completion(true)
            return
        }
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
        source.favorite(item: savedItem)
    }

    private func unfavorite(_ savedItem: SavedItem) {
        source.unfavorite(item: savedItem)
    }

    private func confirmDelete(for savedItem: SavedItem) {
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
        sharedActivity = PocketItemActivity.fromCollection(url: url, additionalText: additionalText)
    }

    private func report() {
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

    /// Check if collection does not have local data, then show error state
    private func checkForLocalData() {
        guard !hasLocalData else { return }
        snapshot = self.errorSnapshot()
        return
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
            // TODO: NATIVE COLLECTIONS - Handle fetching
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
            overflowActions: [
                .share { [weak self] sender in
                    self?.sharedStoryActivity = PocketItemActivity.fromCollection(url: story.url, sender: sender)
                },
                .report { [weak self] _ in
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
            selectItem(with: storyViewModel.collectionStory)
        }
    }

    private func selectItem(with story: CollectionStory) {
        // Check if item is a saved item
        if let item = story.item, !item.shouldOpenInWebView(override: featureFlags.shouldDisableReader), let savedItem = item.savedItem {
            selectedReadableViewModel = SavedItemViewModel(
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
        // Check if item has an associated recommendation
        } else if let item = story.item, !item.shouldOpenInWebView(override: featureFlags.shouldDisableReader), let recommendation = item.recommendation {
            selectedReadableViewModel =
            RecommendationViewModel(
                recommendation: recommendation,
                source: source,
                tracker: tracker,
                pasteboard: UIPasteboard.general,
                user: user,
                userDefaults: userDefaults
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
            setCollectionSnapshot(convertToManagedObjectIds(snapshot.itemIdentifiers))
        } else {
            updateCollectionSnapshot(
                convertToManagedObjectIds(snapshot.reloadedItemIdentifiers),
                reconfigurableIdentifiers: convertToManagedObjectIds(snapshot.reconfiguredItemIdentifiers)
            )
        }
    }
}

// TODO: NATIVE COLLECTIONS - Update when working on analytics ticket
extension CollectionViewModel {
    func trackerForReportRecommendation() -> Tracker {
        tracker.childTracker(hosting: .reportDialog)
    }
}
