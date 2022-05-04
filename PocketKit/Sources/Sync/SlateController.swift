import Foundation
import CoreData


public protocol SlateControllerDelegate: AnyObject {
    func controller(
        _ controller: SlateController,
        didChange slate: Slate,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    )

    func controllerDidChangeContent(_ controller: SlateController)
}

public protocol SlateController: AnyObject {
    var delegate: SlateControllerDelegate? { get set }

    var slate: Slate? { get }

    func performFetch() throws
}

class PocketSlateController: NSObject, SlateController {
    weak var delegate: SlateControllerDelegate?

    private let resultsController: NSFetchedResultsController<Slate>

    init(resultsController: NSFetchedResultsController<Slate>) {
        self.resultsController = resultsController

        super.init()

        resultsController.delegate = self
    }

    var slate: Slate? {
        resultsController.fetchedObjects?.first
    }

    func performFetch() throws {
        try resultsController.performFetch()
    }
}

extension PocketSlateController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let slate = anObject as? Slate else {
            return
        }

        delegate?.controller(
            self,
            didChange: slate,
            at: indexPath,
            for: type,
            newIndexPath: newIndexPath
        )
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}

