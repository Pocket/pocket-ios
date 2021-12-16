import CoreData
import Sync
import Analytics
import Combine
import UIKit


class MyListViewModel: NSObject {
    private let source: Source
    private let tracker: Tracker
    private let main: MainViewModel
    private let itemsController: NSFetchedResultsController<SavedItem>
    private var subscriptions: [AnyCancellable] = []

    let events = MyListEvents()

    var count: Int {
        itemsController.fetchedObjects?.count ?? 0
    }

    init(source: Source, tracker: Tracker, main: MainViewModel) {
        self.source = source
        self.tracker = tracker
        self.main = main
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        self.main.$selectedItem.sink { [weak self] savedItem in
            self?.events.send(.itemSelected(savedItem))
        }.store(in: &subscriptions)
    }

    func fetch() throws {
        try itemsController.performFetch()
    }

    func refresh(_ completion: (() -> ())? = nil) {
        source.refresh(completion: completion)
    }

    func item(at indexPath: IndexPath) -> MyListItemViewModel? {
        bareItem(at: indexPath).flatMap { item in
            MyListItemViewModel(
                item: item,
                index: indexPath.item,
                source: source,
                tracker: tracker
            )
        }
    }

    func selectItem(at indexPath: IndexPath) {
        main.selectedItem = bareItem(at: indexPath)
    }

    func shareItem(at indexPath: IndexPath) {
        main.sharedActivity = bareItem(at: indexPath).flatMap { PocketItemActivity(item: $0) }
    }

    private func bareItem(at indexPath: IndexPath) -> SavedItem? {
        itemsController.fetchedObjects?[indexPath.item]
    }
}

extension MyListViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let _snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        events.send(.itemsLoaded(_snapshot))
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
            // other changes are handled by `controller(_: didChangeContentWith:)`
            break
        }
    }
}

extension MyListViewModel {
    enum Event {
        case itemSelected(SavedItem?)
        case itemUpdated(NSManagedObjectID)
        case itemsLoaded(NSDiffableDataSourceSnapshot<String, NSManagedObjectID>)
    }

    typealias MyListEvents = PassthroughSubject<Event, Never>
}
