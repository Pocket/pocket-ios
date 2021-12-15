import CoreData
import Sync
import Analytics
import Combine


class MyListViewModel: NSObject {
    private let source: Source
    private let tracker: Tracker
    private let itemsController: NSFetchedResultsController<SavedItem>

    let events = MyListEvents()

    @Published
    private(set) var items: [MyListItemViewModel]?

    var count: Int {
        items?.count ?? 0
    }

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self
    }

    func fetch() throws {
        try itemsController.performFetch()
        updateItems()
    }

    func refresh(_ completion: (() -> ())? = nil) {
        source.refresh(completion: completion)
    }

    private func updateItems() {
        items = itemsController.fetchedObjects?.enumerated().map { index, item in
            MyListItemViewModel(
                item: item,
                index: index,
                source: source,
                tracker: tracker.childTracker(hosting: .myList.item(index: UInt(index)))
            )
        }
    }
}

extension MyListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateItems()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .update:
            guard let id = (anObject as? NSManagedObject)?.objectID else {
                return
            }

            events.send(.itemUpdated(id))
        default:
            // delete, insert, move are handled by the general `controllerDidChangeContent` handler
            break
        }
    }
}

extension MyListViewModel {
    enum Event {
        case itemUpdated(NSManagedObjectID)
    }

    typealias MyListEvents = PassthroughSubject<Event, Never>
}
