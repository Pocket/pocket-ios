import Combine
import CoreData


public class RecentSavesController: NSObject {
    @Published
    private(set) public var recentSaves: [SavedItem]

    public let itemChanged: PassthroughSubject<SavedItem, Never> = .init()
    
    private let space: Space
    private let savedItemsController: NSFetchedResultsController<SavedItem>

    init(space: Space) {
        self.space = space
        self.savedItemsController = space.makeItemsController()
        try? savedItemsController.performFetch()
        recentSaves = savedItemsController.fetchedObjects.flatMap({ Array($0.prefix(5)) }) ?? []
        
        super.init()
        
        savedItemsController.delegate = self
    }
}

extension RecentSavesController: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        if let _recentSaves = savedItemsController.fetchedObjects.flatMap({ Array($0.prefix(5)) }),
        _recentSaves != recentSaves {
            recentSaves = _recentSaves
        }
    }

    public func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard type == .update,
              let savedItem = anObject as? SavedItem,
              recentSaves.contains(savedItem) else {
            return
        }

        itemChanged.send(savedItem)
    }
}
