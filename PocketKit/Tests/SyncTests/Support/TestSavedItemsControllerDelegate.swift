import Foundation
import CoreData
import Sync
import UIKit

class TestSavedItemsControllerDelegate: SavedItemsControllerDelegate {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    func controller(_ controller: SavedItemsController, didChange aSavedItem: SavedItem, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }

    func controller(_ controller: SavedItemsController, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        handler()
    }
}
