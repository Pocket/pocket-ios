import Foundation
import CoreData


public protocol SavedItemsControllerDelegate: AnyObject {
    func controller(
        _ controller: SavedItemsController,
        didChange aSavedItem: SavedItem,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    )

    func controllerDidChangeContent(_ controller: SavedItemsController)
}

public protocol SavedItemsController: AnyObject {
    var delegate: SavedItemsControllerDelegate? { get set }

    var predicate: NSPredicate? { get set }

    var fetchedObjects: [SavedItem]? { get }

    func performFetch() throws

    func indexPath(forObject: SavedItem) -> IndexPath?
}

class FetchedSavedItemsController: NSObject, SavedItemsController {
    weak var delegate: SavedItemsControllerDelegate?

    private let resultsController: NSFetchedResultsController<SavedItem>

    init(resultsController: NSFetchedResultsController<SavedItem>) {
        self.resultsController = resultsController

        super.init()

        resultsController.delegate = self
    }

    var predicate: NSPredicate? {
        get { resultsController.fetchRequest.predicate }
        set { resultsController.fetchRequest.predicate = newValue }
    }

    var fetchedObjects: [SavedItem]? {
        resultsController.fetchedObjects
    }

    func performFetch() throws {
        try resultsController.performFetch()
    }

    func indexPath(forObject object: SavedItem) -> IndexPath? {
        resultsController.indexPath(forObject: object)
    }
}

extension FetchedSavedItemsController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let savedItem = anObject as? SavedItem else {
            return
        }

        delegate?.controller(self, didChange: savedItem, at: indexPath, for: type, newIndexPath: newIndexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}
