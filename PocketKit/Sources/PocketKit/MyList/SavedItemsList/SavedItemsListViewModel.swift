import CoreData
import Sync
import Analytics
import Combine
import UIKit


class SavedItemsListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID

    private let source: Source
    private let tracker: Tracker
    private let main: MainViewModel
    private let itemsController: NSFetchedResultsController<SavedItem>
    private var subscriptions: [AnyCancellable] = []

    @Published
    private var selectedFilters: Set<ItemsListFilter>
    private let availableFilters: [ItemsListFilter]

    let events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    let selectionItem: SelectionItem = SelectionItem(title: "My List", image: .init(asset: .myList))

    var presentedAlert: PocketAlert? {
        get {
            main.presentedAlert
        }
        set {
            main.presentedAlert = newValue
        }
    }

    init(source: Source, tracker: Tracker, main: MainViewModel) {
        self.source = source
        self.tracker = tracker
        self.main = main
        self.selectedFilters = []
        self.availableFilters = ItemsListFilter.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        self.main.$selectedMyListReadableViewModel.sink { _ in
            // TODO: Handle deselection here
        }.store(in: &subscriptions)
    }

    func fetch() throws {
        $selectedFilters.receive(on: DispatchQueue.main).sink { [weak self] selectedFilters in
            guard let self = self else { return }
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
        }.store(in: &subscriptions)
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
            guard let item = bareItem(with: objectID) else {
                return 
            }
            let viewModel = SavedItemViewModel(
                item: item,
                source: source,
                mainViewModel: main,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
            main.selectedMyListReadableViewModel = viewModel
        case .filterButton(let filterID):
            if selectedFilters.contains(filterID) {
                selectedFilters.remove(filterID)
            } else {
                selectedFilters.insert(filterID)
            }

            var snapshot = buildSnapshot()
            snapshot.reloadItems([cellID])
            send(snapshot: snapshot)
        }
    }

    func shareItem(with itemID: ItemsListCell<ItemIdentifier>) {
        guard case .item(let objectID) = itemID else {
            return
        }

        main.sharedActivity = bareItem(with: objectID).flatMap { PocketItemActivity(url: $0.url) }
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.object(id: id)
    }

    private func itemsLoaded() {
        send(snapshot: buildSnapshot())
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> = .init()
        snapshot.appendSections(ItemsListSection.allCases)

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
        events.send(.snapshot(snapshot))
    }
    
    func toggleFavorite(_ cell: ItemsListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            if item.isFavorite {
                self.source.unfavorite(item: item)
                self.track(item: item, identifier: .itemUnfavorite)
            } else {
                self.source.favorite(item: item)
                self.track(item: item, identifier: .itemFavorite)
            }
        }
    }
    
    func archive(_ cell: ItemsListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            self.source.archive(item: item)
            self.track(item: item, identifier: .itemArchive)
        }
    }
    
    func delete(_ cell: ItemsListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            self.source.delete(item: item)
            self.track(item: item, identifier: .itemDelete)
        }
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
