import Foundation
import CoreData
import Sync


class TestSavedItemsControllerDelegate: SavedItemsControllerDelegate {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    func controllerDidChangeContent(_ controller: SavedItemsController) {
        handler()
    }

    func controller(_ controller: SavedItemsController, didChange aSavedItem: SavedItem, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    }
}
