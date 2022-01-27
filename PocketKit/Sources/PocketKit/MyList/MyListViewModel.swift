import CoreData
import Sync
import Analytics
import Combine
import UIKit


class MyListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID

    private let source: Source
    private let tracker: Tracker
    private let main: MainViewModel
    private let itemsController: NSFetchedResultsController<SavedItem>
    private var subscriptions: [AnyCancellable] = []

    @Published
    private var selectedFilters: Set<ItemListFilter>
    private let availableFilters: [ItemListFilter]

    let events: PassthroughSubject<ItemListEvent<ItemIdentifier>, Never> = .init()
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
        self.availableFilters = ItemListFilter.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        self.main.$selectedItem.sink { [weak self] savedItem in
            // TODO: Handle deselection here
//            self?.events.send(.itemSelected(savedItem))
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

    func item(with cellID: ItemListCell<ItemIdentifier>) -> MyListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return item(with: objectID)
    }

    func item(with itemID: ItemIdentifier) -> MyListItemPresenter? {
        guard let savedItem = bareItem(with: itemID),
              let indexPath = itemsController.indexPath(forObject: savedItem) else {
                  return nil
              }

        return MyListItemPresenter(item: savedItem)
    }

    func filterButton(with filterID: ItemListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: filterID.rawValue,
            isSelected: selectedFilters.contains(filterID)
        )
    }

    func selectCell(with cellID: ItemListCell<ItemIdentifier>) {
        switch cellID {
        case .item(let objectID):
            main.selectedItem = bareItem(with: objectID)
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

    func shareItem(with itemID: ItemListCell<ItemIdentifier>) {
        guard case .item(let objectID) = itemID else {
            return
        }

        main.sharedActivity = bareItem(with: objectID).flatMap { PocketItemActivity(item: $0) }
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.object(id: id)
    }

    private func itemsLoaded() {
        send(snapshot: buildSnapshot())
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemListSection, ItemListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemListSection, ItemListCell<ItemIdentifier>> = .init()
        snapshot.appendSections(ItemListSection.allCases)

        snapshot.appendItems(
            ItemListFilter.allCases.map { ItemListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        guard let itemCellIDs = itemsController.fetchedObjects?.map({ ItemListCell<ItemIdentifier>.item($0.objectID) }) else {
            return snapshot
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    private func send(snapshot: NSDiffableDataSourceSnapshot<ItemListSection, ItemListCell<ItemIdentifier>>) {
        events.send(.snapshot(snapshot))
    }
    
    func toggleFavorite(_ cell: ItemListCell<ItemIdentifier>) {
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
    
    func archive(_ cell: ItemListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            self.source.archive(item: item)
            self.track(item: item, identifier: .itemArchive)
        }
    }
    
    func delete(_ cell: ItemListCell<ItemIdentifier>) {
        withSavedItem(from: cell) { item in
            self.source.delete(item: item)
            self.track(item: item, identifier: .itemDelete)
        }
    }
    
    func trackImpression(_ cell: ItemListCell<ItemIdentifier>) {
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
    
    private func withSavedItem(from cell: ItemListCell<ItemIdentifier>, handler: ((SavedItem) -> Void)?) {
        guard case .item(let identifier) = cell, let item = bareItem(with: identifier) else {
            return
        }
        
        handler?(item)
    }
}

extension MyListViewModel: NSFetchedResultsControllerDelegate {
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
        snapshot.reloadItems([ItemListCell<ItemIdentifier>.item(id)])
        send(snapshot: snapshot)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemsLoaded()
    }
}
