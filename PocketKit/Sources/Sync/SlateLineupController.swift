import Foundation
import CoreData


public protocol SlateLineupControllerDelegate: AnyObject {
    func controller(
        _ controller: SlateLineupController,
        didChange slateLineup: SlateLineup,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    )

    func controllerDidChangeContent(_ controller: SlateLineupController)
}

public protocol SlateLineupController: AnyObject {
    var delegate: SlateLineupControllerDelegate? { get set }

    var slateLineup: SlateLineup? { get }

    func performFetch() throws
}

class PocketSlateLineupController: NSObject, SlateLineupController {
    weak var delegate: SlateLineupControllerDelegate?

    private let resultsController: NSFetchedResultsController<SlateLineup>

    init(resultsController: NSFetchedResultsController<SlateLineup>) {
        self.resultsController = resultsController

        super.init()

        resultsController.delegate = self
    }

    var slateLineup: SlateLineup? {
        resultsController.fetchedObjects?.first
    }

    func performFetch() throws {
        try resultsController.performFetch()
    }
}

extension PocketSlateLineupController: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let lineup = anObject as? SlateLineup else {
            return
        }

        delegate?.controller(self, didChange: lineup, at: indexPath, for: type, newIndexPath: newIndexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}
