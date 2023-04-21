import CoreData
import Sync
import Analytics
import Combine
import UIKit
import Localization
import SharedPocketKit
import Textile

public enum SavesViewType {
    case saves
    case archive
}

class SavedItemsListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    var selectionItem: SelectionItem {
        switch self.viewType {
        case .saves:
            return SelectionItem(title: Localization.saves, image: .init(asset: .saves), selectedView: SelectedView.saves)
        case .archive:
            return SelectionItem(title: Localization.archive, image: .init(asset: .archive), selectedView: SelectedView.archive)
        }
    }

    @Published private var _snapshot = Snapshot()
    var snapshot: Published<Snapshot>.Publisher { $_snapshot }

    @Published var presentedAlert: PocketAlert?

    @Published var presentedAddTags: PocketAddTagsViewModel?

    @Published var presentedTagsFilter: TagsFilterViewModel?

    @Published var selectedItem: SelectedItem?

    @Published var sharedActivity: PocketActivity?

    @Published var presentedSortFilterViewModel: SortMenuViewModel?

    @Published
    var presentedListenViewModel: ListenViewModel?

    private let listOptions: ListOptions

    var emptyState: EmptyStateViewModel? {
        let items = itemsController.fetchedObjects ?? []
        guard items.isEmpty else {
            return nil
        }

        if selectedFilters.contains(.favorites) {
            return FavoritesEmptyStateViewModel()
        } else if selectedFilters.contains(.tagged) {
            return TagsEmptyStateViewModel()
        }

        switch self.viewType {
        case .saves:
            return SavesEmptyStateViewModel()
        case .archive:
            return ArchiveEmptyStateViewModel()
        }
    }

    private let source: Source
    private let refreshCoordinator: RefreshCoordinator
    private let tracker: Tracker
    private let itemsController: SavedItemsController
    private let user: User
    private let userDefaults: UserDefaults
    private var subscriptions: [AnyCancellable] = []
    private var store: SubscriptionStore
    private var networkPathMonitor: NetworkPathMonitor
    private var featureFlags: FeatureFlagServiceProtocol

    private var selectedFilters: Set<ItemsListFilter>
    private let availableFilters: [ItemsListFilter]
    private let notificationCenter: NotificationCenter
    private let viewType: SavesViewType

    init(source: Source, tracker: Tracker, viewType: SavesViewType, listOptions: ListOptions, notificationCenter: NotificationCenter, user: User, store: SubscriptionStore, refreshCoordinator: RefreshCoordinator, networkPathMonitor: NetworkPathMonitor, userDefaults: UserDefaults, featureFlags: FeatureFlagServiceProtocol) {
        self.source = source
        self.refreshCoordinator = refreshCoordinator
        self.tracker = tracker
        self.selectedFilters = [.all]
        self.availableFilters = ItemsListFilter.allCases
        self.viewType = viewType
        self.listOptions = listOptions
        self.user = user
        self.store = store
        self.networkPathMonitor = networkPathMonitor
        self.userDefaults = userDefaults
        self.featureFlags = featureFlags

        switch self.viewType {
        case .saves:
            self.itemsController = source.makeSavesController()
        case .archive:
            self.itemsController = source.makeArchiveController()
        }

        self.notificationCenter = notificationCenter

        super.init()

        itemsController.delegate = self

        listOptions
            .objectWillChange
            .dropFirst()
            .receive(on: DispatchQueue.global(qos: .userInitiated)).sink { [weak self] _ in
                self?.fetch()
                self?.presentedSortFilterViewModel = nil
            }
            .store(in: &subscriptions)

        $selectedItem.sink { [weak self] itemSelected in
            guard itemSelected == nil else { return }
            self?._events.send(.selectionCleared)
        }
        .store(in: &subscriptions)

        source.events
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sink { [weak self] event in
                self?.handle(syncEvent: event)
            }
            .store(in: &subscriptions)
    }

    func fetch() {
        let filters = selectedFilters.compactMap { filter -> NSPredicate? in
            switch filter {
            case.listen:
                return nil
            case .favorites:
                return NSPredicate(format: "isFavorite = true")
            case .tagged:
                presentedTagsFilter = TagsFilterViewModel(
                    source: source,
                    tracker: tracker,
                    userDefaults: userDefaults,
                    user: user,
                    selectAllAction: { [weak self] in
                        self?.selectCell(with: .filterButton(.all))
                    }
                )
                presentedTagsFilter?.$selectedTag.sink { [weak self] selectedTag in
                    guard let selectedTag = selectedTag else { return }
                    let predicate: NSPredicate
                    switch selectedTag {
                    case .notTagged:
                        predicate = NSPredicate(format: "tags.@count = 0")
                    case .tag(let name), .recent(let name):
                        predicate = NSPredicate(format: "%@ IN tags.name", name)
                    }
                    self?.fetchItems(with: [predicate])
                    self?.updateSnapshotForTagFilter(with: selectedTag.name)
                }.store(in: &subscriptions)
                return nil
            case .all:
                return nil
            case .sortAndFilter:
                return nil
            }
        }
        applySorting()
        fetchItems(with: filters)
    }

    private func updateSnapshotForTagFilter(with name: String) {
        var snapshot = _snapshot
        let cells = snapshot.itemIdentifiers(inSection: .filters)
        snapshot.reloadItems(cells)
        snapshot.insertSections([.tags], afterSection: .filters)
        snapshot.appendItems([.tag(name)], toSection: .tags)
        self._snapshot = snapshot
    }

    private func fetchItems(with predicates: [NSPredicate]) {
        switch self.viewType {
        case .saves:
            self.itemsController.predicate = Predicates.savedItems(filters: predicates)
        case .archive:
            self.itemsController.predicate = Predicates.archivedItems(filters: predicates)
        }

        try? self.itemsController.performFetch()
    }

    func refresh(_ completion: (() -> Void)? = nil) {
        refreshCoordinator.refresh(isForced: true) {
            completion?()
        }

        source.retryImmediately()
    }

    func preview(for cell: ItemsListCell<NSManagedObjectID>) -> (ReadableViewModel, Bool)? {
        guard case .item(let itemID) = cell else {
            return nil
        }

        guard let savedItem = bareItem(with: itemID) else {
            return nil
        }

        let readable = SavedItemViewModel(
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

        if savedItem.shouldOpenInWebView {
            return (readable, true)
        } else {
            return (readable, false)
        }
    }

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return presenter(for: objectID)
    }

    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }

    func filterButton(with filter: ItemsListFilter) -> TopicChipPresenter {
        return TopicChipPresenter(
            title: filter.localized,
            image: filter.image,
            isSelected: selectedFilters.contains(filter)
        )
    }

    func tagModel(with name: String) -> SelectedTagChipModel {
        SelectedTagChipCell.Model(name: name)
    }

    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool {
        switch cell {
        case .filterButton:
            return true
        case .item(let objectID):
            return !(bareItem(with: objectID)?.isPending ?? true)
        case .offline, .emptyState, .placeholder, .tag:
            return false
        }
    }

    func selectCell(with cellID: ItemsListCell<ItemIdentifier>, sender: Any? = nil) {
        switch cellID {
        case .item(let objectID):
            select(item: objectID)
        case .filterButton(let filterID):
            apply(filter: filterID, from: cellID, sender: sender)
        case .offline, .emptyState, .placeholder, .tag:
            return
        }
    }

    func beginBulkEdit() {
        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: nil,
            detail: Localization.ItemList.Edit.banner
        )

        notificationCenter.post(name: .bannerRequested, object: bannerData)
    }

    func filterByTagAction() -> UIAction? {
        return UIAction(title: "", handler: { [weak self] action in
            let event = SnowplowEngagement(type: .general, value: nil)
            let contexts: Context = UIContext.button(identifier: .tagBadge)
            self?.tracker.track(event: event, [contexts])

            let button = action.sender as? UIButton
            guard let name = button?.titleLabel?.text else { return }
            let predicate = NSPredicate(format: "%@ IN tags.name", name)
            self?.fetchItems(with: [predicate])
            self?.handleFilterSelection(with: .tagged)
            self?.updateSnapshotForTagFilter(with: name)
        })
    }

    func favoriteAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        if item.isFavorite {
            return .unfavorite { [weak self] _ in self?._unfavorite(item: item) }
        } else {
            return .favorite { [weak self] _ in self?._favorite(item: item) }
        }
    }

    private func _favorite(item: SavedItem) {
        track(item: item, identifier: .itemFavorite)
        source.favorite(item: item)
    }

    private func _unfavorite(item: SavedItem) {
        track(item: item, identifier: .itemUnfavorite)
        source.unfavorite(item: item)
    }

    func shareAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        return .share { [weak self] sender in self?._share(item: item, sender: sender) }
    }

    func _share(item: SavedItem, sender: Any?) {
        track(item: item, identifier: .itemShare)
        // This view model is used within the context of a view that is presented within Saves
        sharedActivity = PocketItemActivity.fromSaves(url: item.url, sender: sender)
    }

    func overflowActions(for objectID: NSManagedObjectID) -> [ItemAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        switch self.viewType {
        case .saves:
            return [
                .addTags { [weak self] _ in self?.showAddTagsView(item: item) },
                .archive { [weak self] _ in self?._archive(item: item) },
                .delete { [weak self] _ in self?.confirmDelete(item: item) }
            ]
        case .archive:
            return [
                .addTags { [weak self] _ in self?.showAddTagsView(item: item) },
                .moveToSaves { [weak self] _ in self?._moveToSaves(item: item) },
                .delete { [weak self] _ in self?.confirmDelete(item: item) }
            ]
        }
    }

    func trackOverflow(for objectID: NSManagedObjectID) -> UIAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }
        return UIAction(title: "", handler: { [weak self] _ in
            Haptics.overflowTap()
            self?.trackButton(item: item, identifier: .itemOverflow)
        })
    }

    func swiftUITrackOverflow(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }
        return ItemAction(title: "", identifier: UIAction.Identifier(rawValue: ""), accessibilityIdentifier: "", image: nil) { [weak self] _ in
            Haptics.overflowTap()
            self?.trackButton(item: item, identifier: .itemOverflow)
        }
    }

    func trailingSwipeActions(for objectID: NSManagedObjectID) -> [ItemContextualAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        switch self.viewType {
        case .saves:
            return [
                .archive { [weak self] completion in
                    self?._archive(item: item)
                    completion(true)
                }
            ]
        case .archive:
            return [
                .moveToSaves { [weak self] completion in
                    self?._moveToSaves(item: item)
                    completion(true)
                }
            ]
        }
    }

    private func _archive(item: SavedItem) {
        track(item: item, identifier: .itemArchive)
        source.archive(item: item)
    }

    private func _moveToSaves(item: SavedItem) {
        track(item: item, identifier: .itemSave)
        source.unarchive(item: item)
    }

    private func confirmDelete(item: SavedItem) {
        presentedAlert = PocketAlert(
            title: Localization.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: Localization.yes, style: .destructive) { [weak self] _ in
                    self?._delete(item: item)
                }
            ],
            preferredAction: nil
        )
    }

    private func _delete(item: SavedItem) {
        track(item: item, identifier: .itemDelete)
        presentedAlert = nil
        source.delete(item: item)
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.viewObject(id: id)
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> = .init()
        let sections: [ItemsListSection] = [.filters]
        snapshot.appendSections(sections)

        var cases = ItemsListFilter.allCases
        if !self.featureFlags.isAssigned(flag: .listen) {
            cases.removeAll(where: {$0 == .listen})
        }
        snapshot.appendItems(
            cases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let filters = snapshot.itemIdentifiers(inSection: .filters)
        snapshot.reloadItems(filters)
        let itemCellIDs: [ItemsListCell<ItemIdentifier>]

        var stateValue: InitialDownloadState
        switch self.viewType {
        case .saves:
            stateValue = source.initialSavesDownloadState.value
        case .archive:
            stateValue = source.initialArchiveDownloadState.value
        }

        switch stateValue {
        case .unknown, .completed:
            itemCellIDs = itemsController
                .fetchedObjects?
                .map { .item($0.objectID) } ?? []
        case .started:
            // If you background the app, and reopen the Fetch operations can override the sent staus,
            // so instead we will first make sure we have no objects before switching to placeholders.
            if let fetchedObjects = itemsController.fetchedObjects, fetchedObjects.count > 0 {
                itemCellIDs = (0..<fetchedObjects.count).compactMap { index in
                    .item(fetchedObjects[index].objectID)
                }
            } else {
                itemCellIDs = (0..<4).map { .placeholder($0) }
            }
        case .paginating(let totalCount):
            itemCellIDs = (0..<totalCount).compactMap { index in
                guard let fetchedObjects = itemsController.fetchedObjects,
                      fetchedObjects.count > index else {
                    return .placeholder(index)
                }

                return .item(fetchedObjects[index].objectID)
            }
        }

        guard !itemCellIDs.isEmpty else {
            snapshot.appendSections([.emptyState])
            snapshot.appendItems([ItemsListCell<ItemIdentifier>.emptyState], toSection: .emptyState)
            snapshot.reloadSections([.emptyState])
            return snapshot
        }

        snapshot.appendSections([.items])
        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    func willDisplay(_ cell: ItemsListCell<NSManagedObjectID>) {
        if case .item = cell {
            withSavedItem(from: cell) { item in
                self.trackImpression(of: item)
            }
        }
    }

    private func track(item: SavedItem, identifier: UIContext.Identifier) {
        guard let url = item.bestURL, let indexPath = itemsController.indexPath(forObject: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.saves.item(index: UIIndex(indexPath.item)),
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        if selectedFilters.contains(.favorites) {
            contexts.insert(UIContext.saves.favorites, at: 0)
        }

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }

    private func trackContentOpen(destination: ContentOpenEvent.Destination, item: SavedItem) {
        guard let url = item.bestURL else {
            return
        }

        let contexts: [Context] = [
            ContentContext(url: url)
        ]

        let event = ContentOpenEvent(destination: destination, trigger: .click)
        tracker.track(event: event, contexts)
    }

    private func trackButton(item: SavedItem, identifier: UIContext.Identifier) {
        guard let url = item.bestURL else {
            return
        }

        let contexts: [Context] = [
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }

    private func trackImpression(of item: SavedItem) {
        guard let url = item.bestURL, let indexPath = self.itemsController.indexPath(forObject: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.saves.item(index: UIIndex(indexPath.item)),
            ContentContext(url: url)
        ]

        if selectedFilters.contains(.favorites) {
            contexts.insert(UIContext.saves.favorites, at: 0)
        }

        let event = ImpressionEvent(component: .card, requirement: .instant)
        self.tracker.track(event: event, contexts)
    }

    private func withSavedItem(from cell: ItemsListCell<ItemIdentifier>, handler: ((SavedItem) -> Void)?) {
        guard case .item(let identifier) = cell, let item = bareItem(with: identifier) else {
            return
        }

        handler?(item)
    }
}

extension SavedItemsListViewModel {
    private func select(item itemID: ItemIdentifier) {
        guard let savedItem = bareItem(with: itemID) else {
            return
        }

        let readable = SavedItemViewModel(
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

        if savedItem.shouldOpenInWebView {
            selectedItem = .webView(readable)

            trackContentOpen(destination: .external, item: savedItem)
        } else {
            selectedItem = .readable(readable)

            trackContentOpen(destination: .internal, item: savedItem)
        }
    }

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>, sender: Any? = nil) {
        handleFilterSelection(with: filter, sender: sender)

        fetch()
    }

    private func applySorting() {
        var sortDescriptorTemp: NSSortDescriptor?

        switch listOptions.selectedSortOption {
        case .longestToRead, .shortestToRead:
            sortDescriptorTemp = NSSortDescriptor(keyPath: \SavedItem.item.timeToRead, ascending: (listOptions.selectedSortOption == .shortestToRead))
        case .newest, .oldest:

            switch self.viewType {
            case .saves:
                sortDescriptorTemp = NSSortDescriptor(keyPath: \SavedItem.createdAt, ascending: (listOptions.selectedSortOption == .oldest))
            case .archive:
                sortDescriptorTemp = NSSortDescriptor(keyPath: \SavedItem.archivedAt, ascending: (listOptions.selectedSortOption == .oldest))
            }
        }

        guard let sortDescriptor = sortDescriptorTemp else {
            assertionFailure("sortDescriptorTemp can not be nil!")
            return
        }
        self.itemsController.sortDescriptors = [sortDescriptor]
    }

    private func handleFilterSelection(with filter: ItemsListFilter, sender: Any? = nil) {
        let reTappedTagFilter = selectedFilters.contains(.tagged) && filter == .tagged
        guard !reTappedTagFilter else { return }

        switch filter {
        case .listen:
            // If the user selected a filter, and the user is not in the Listen tags playlist feature flag
            // Remove any filters and sorts they selected and re-fetch data before showing listen.
            if !selectedFilters.isEmpty && !featureFlags.isAssigned(flag: .listenTagsPlaylists) {
                selectedFilters.removeAll()
                applySorting()
                fetch()
            }
            presentedListenViewModel = ListenViewModel.source(savedItems: self.itemsController.fetchedObjects)
            selectedFilters.remove(.listen)
        case .all:
            selectedFilters.removeAll()
            selectedFilters.insert(.all)
        case .sortAndFilter:
            guard let sender = sender else { return }
            presentedSortFilterViewModel = SortMenuViewModel(
                source: source,
                tracker: tracker.childTracker(hosting: .saves.sortFilterSheet),
                listOptions: listOptions,
                sender: sender
            )
        case .tagged:
            filterTagAnalytics()
            selectedFilters.removeAll()
            selectedFilters.insert(filter)
        default:
            if selectedFilters.contains(filter) {
                selectedFilters.remove(filter)
                selectedFilters.insert(.all)
            } else {
                selectedFilters.removeAll()
                selectedFilters.insert(filter)
            }
        }
    }

    private func filterTagAnalytics() {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: Context = UIContext.button(identifier: .taggedChip)
        tracker.track(event: event, [contexts])
    }
}

extension SavedItemsListViewModel: SavedItemsControllerDelegate {
    func controller(
        _ controller: SavedItemsController,
        didChange savedItem: SavedItem,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        // no-op
    }

    /**
     Sets our custom snapshot to reload certain identifiers based on the NSFetched Results controller.
     When reloading data in this view, always call itemController.performFetch which will end up calling this function.
     */
    func controller(_ controller: SavedItemsController, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        // Build up a snapshot for us to use
        var newSnapshot = buildSnapshot()

        // Grab any ids that have changed, map them to .item and then setup our custom snapshot to reload them
        let idsToReload: [ItemsListCell<ItemIdentifier>] =  snapshot.reloadedItemIdentifiers.compactMap({ .item($0 as! NSManagedObjectID) })
        let idsToReconfigure: [ItemsListCell<ItemIdentifier>] =  snapshot.reconfiguredItemIdentifiers.compactMap({ .item($0 as! NSManagedObjectID) })
        newSnapshot.reloadItems(idsToReload)
        newSnapshot.reconfigureItems(idsToReconfigure)

        // Set the new snapshot which is subscribed to in ItemListController and will apply this snapshot over the existing one
        _snapshot = newSnapshot
        notificationCenter.post(name: .listUpdated, object: nil)
    }
}

// MARK: - Add Tags to an item
extension SavedItemsListViewModel {
    private func showAddTagsView(item: SavedItem) {
        presentedAddTags = PocketAddTagsViewModel(
            item: item,
            source: source,
            tracker: tracker,
            userDefaults: userDefaults,
            user: user,
            store: store,
            networkPathMonitor: networkPathMonitor,
            saveAction: { [weak self] in
                self?.refresh()
            }
        )
        trackButton(item: item, identifier: .itemEditTags)
    }
}

// MARK: - handling sync events
extension SavedItemsListViewModel {
    private func handle(syncEvent: SyncEvent) {
        switch syncEvent {
        case .error, .loadedArchivePage:
            break
        case .savedItemCreated, .savedItemsUpdated:
            fetch()
        }
    }
}

// MARK: - Prefetching data
extension SavedItemsListViewModel {
    func prefetch(itemsAt: [IndexPath]) {
        // no op
    }
}

// MARK: - Clearing presented content
extension SavedItemsListViewModel {
    func clearSharedActivity() {
        sharedActivity = nil
        selectedItem?.clearSharedActivity()
    }

    func clearPresentedWebReaderURL() {
        switch selectedItem {
        case .readable(let readable):
            readable?.clearPresentedWebReaderURL()
        case .webView:
            selectedItem = nil
        case .none:
            break
        }
    }

    func clearIsPresentingReaderSettings() {
        selectedItem?.clearIsPresentingReaderSettings()
    }

    func clearSelectedItem() {
        selectedItem = nil
    }
}
