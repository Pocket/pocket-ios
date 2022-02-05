import CoreData
import Sync
import Analytics
import Combine
import UIKit


class SavedItemsListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    let selectionItem: SelectionItem = SelectionItem(title: "My List", image: .init(asset: .myList))

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var selectedReadable: SavedItemViewModel?

    @Published
    var sharedActivity: PocketActivity?

    private let source: Source
    private let tracker: Tracker
    private let itemsController: NSFetchedResultsController<SavedItem>
    private var subscriptions: [AnyCancellable] = []

    private var selectedFilters: Set<ItemsListFilter>
    private let availableFilters: [ItemsListFilter]

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
        self.selectedFilters = []
        self.availableFilters = ItemsListFilter.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

//        self.main.$selectedMyListReadableViewModel.sink { _ in
//            // TODO: Handle deselection here
//        }.store(in: &subscriptions)
    }

    func fetch() {
        var predicates: [NSPredicate] = []

        for filter in selectedFilters {
            switch filter {
            case .favorites:
                predicates.append(NSPredicate(format: "isFavorite = true", true))
            }
        }

        self.itemsController.fetchRequest.predicate = Predicates.savedItems(filters: predicates)

        try? self.itemsController.performFetch()
        self.itemsLoaded()
    }

    func refresh(_ completion: (() -> ())? = nil) {
        source.refresh(completion: completion)
    }

    func item(with cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return item(with: objectID)
    }

    func item(with itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }

    func filterButton(with filterID: ItemsListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: filterID.rawValue,
            isSelected: selectedFilters.contains(filterID)
        )
    }

    func selectCell(with cellID: ItemsListCell<ItemIdentifier>) {
        switch cellID {
        case .item(let objectID):
            select(item: objectID)
        case .filterButton(let filterID):
            apply(filter: filterID, from: cellID)
        case .offline:
            return
        }
    }

    func favoriteAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        if item.isFavorite {
            return .unfavorite { [weak self] _ in
                self?.source.unfavorite(item: item)
                self?.track(item: item, identifier: .itemUnfavorite)
            }
        } else {
            return .favorite { [weak self] _ in
                self?.source.favorite(item: item)
                self?.track(item: item, identifier: .itemFavorite)
            }
        }
    }

    func shareAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        return .share { [weak self] sender in
            self?.sharedActivity = PocketItemActivity(url: item.url, sender: sender)
        }
    }

    func overflowActions(for objectID: NSManagedObjectID) -> [ItemAction]? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        return [
            .archive { [weak self] _ in
                self?.archive(item: item)
            },
            .delete { [weak self] _ in
                self?.confirmDelete(item: item)
            }
        ]
    }

    func trailingSwipeActions(for objectID: NSManagedObjectID) -> [UIContextualAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        let archiveAction = UIContextualAction(style: .normal, title: "Archive") { [weak self] _, _, completion in
            self?.archive(item: item)
            completion(true)
        }
        archiveAction.backgroundColor = UIColor(.ui.lapis1)

        return [archiveAction]
    }

    private func archive(item: SavedItem) {
        source.archive(item: item)
        track(item: item, identifier: .itemArchive)
    }

    private func confirmDelete(item: SavedItem) {
        presentedAlert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: "No", style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                    self?.presentedAlert = nil
                    self?.source.delete(item: item)
                    self?.track(item: item, identifier: .itemDelete)
                }
            ],
            preferredAction: nil
        )
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.object(id: id)
    }

    private func itemsLoaded() {
        send(snapshot: buildSnapshot())
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> = .init()

        let sections: [ItemsListSection] = [.filters, .items]
        snapshot.appendSections(sections)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        guard let itemCellIDs = itemsController.fetchedObjects?.map({ ItemsListCell<ItemIdentifier>.item($0.objectID) }) else {
            return snapshot
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    private func send(snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>) {
        _events.send(.snapshot(snapshot))
    }

    func trackImpression(_ cell: ItemsListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            guard let url = item.bestURL, let indexPath = self.itemsController.indexPath(forObject: item) else {
                return
            }

            let contexts: [Context] = [
                UIContext.myList.item(index: UIIndex(indexPath.item)),
                ContentContext(url: url)
            ]

            let event = ImpressionEvent(component: .card, requirement: .instant)
            self.tracker.track(event: event, contexts)
        }
    }

    private func track(item: SavedItem, identifier: UIContext.Identifier) {
        guard let url = item.bestURL, let indexPath = itemsController.indexPath(forObject: item) else {
            return
        }

        let contexts: [Context] = [
            UIContext.myList.item(index: UIIndex(indexPath.item)),
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
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
        selectedReadable = bareItem(with: itemID).flatMap {
            SavedItemViewModel(
                item: $0,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
        }
    }

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }

        var snapshot = buildSnapshot()
        snapshot.reloadItems([cell])
        send(snapshot: snapshot)

        fetch()
    }
}

extension SavedItemsListViewModel: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard .update == type, let id = (anObject as? SavedItem)?.objectID else {
            return
        }

        var snapshot = buildSnapshot()
        snapshot.reloadItems([ItemsListCell<ItemIdentifier>.item(id)])
        send(snapshot: snapshot)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemsLoaded()
    }
}
