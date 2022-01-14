import CoreData
import Sync
import Analytics
import Combine
import UIKit


enum MyListSectionID: Int, CaseIterable {
    case filters
    case items
}

enum MyListCellID: Hashable {
    case filterButton(MyListFilterID)
    case item(NSManagedObjectID)
}

enum MyListFilterID: String, Hashable, CaseIterable {
    case favorites = "Favorites"
}

class MyListViewModel: NSObject {
    private let source: Source
    private let tracker: Tracker
    private let main: MainViewModel
    private let itemsController: NSFetchedResultsController<SavedItem>
    private var subscriptions: [AnyCancellable] = []

    @Published
    private var selectedFilters: Set<MyListFilterID>
    private let availableFilters: [MyListFilterID]

    let events = MyListEvents()

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
        self.availableFilters = MyListFilterID.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        self.main.$selectedItem.sink { [weak self] savedItem in
            self?.events.send(.itemSelected(savedItem))
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

    func item(for cellID: MyListCellID) -> MyListItemViewModel? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return item(with: objectID)
    }

    func item(with objectID: NSManagedObjectID) -> MyListItemViewModel? {
        guard let savedItem = bareItem(with: objectID),
              let indexPath = itemsController.indexPath(forObject: savedItem) else {
                  return nil
              }

        return MyListItemViewModel(
            item: savedItem,
            index: indexPath.item,
            source: source,
            tracker: tracker
        )
    }

    func filterButton(with filterID: MyListFilterID) -> TopicChipPresenter {
        TopicChipPresenter(
            title: filterID.rawValue,
            isSelected: selectedFilters.contains(filterID)
        )
    }

    func selectCell(with cellID: MyListCellID) {
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

    func shareItem(with itemID: MyListCellID) {
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

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<MyListSectionID, MyListCellID> {
        var snapshot: NSDiffableDataSourceSnapshot<MyListSectionID, MyListCellID> = .init()
        snapshot.appendSections(MyListSectionID.allCases)

        snapshot.appendItems(
            MyListFilterID.allCases.map { MyListCellID.filterButton($0) },
            toSection: .filters
        )

        guard let itemCellIDs = itemsController.fetchedObjects?.map({ MyListCellID.item($0.objectID) }) else {
            return snapshot
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    private func send(snapshot: NSDiffableDataSourceSnapshot<MyListSectionID, MyListCellID>) {
        events.send(.snapshot(snapshot))
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
        snapshot.reloadItems([MyListCellID.item(id)])
        send(snapshot: snapshot)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemsLoaded()
    }
}

extension MyListViewModel {
    enum Event {
        case itemSelected(SavedItem?)
        case snapshot(NSDiffableDataSourceSnapshot<MyListSectionID, MyListCellID>)
    }

    typealias MyListEvents = PassthroughSubject<Event, Never>
}
