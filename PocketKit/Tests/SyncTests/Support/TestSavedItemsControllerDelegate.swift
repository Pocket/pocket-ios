// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import Sync
import UIKit

class TestSavedItemsControllerDelegate: SavedItemsControllerDelegate {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    func controller(_ controller: SavedItemsController, didChange aSavedItem: CDSavedItem, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }

    func controller(_ controller: SavedItemsController, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        handler()
    }
}
