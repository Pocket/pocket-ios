// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import UIKit

public protocol SavedItemsControllerDelegate: AnyObject {
    func controller(
        _ controller: SavedItemsController,
        didChange aSavedItem: SavedItem,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    )

    func controller(_ controller: SavedItemsController, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference)
}

public protocol SavedItemsController: AnyObject {
    var delegate: SavedItemsControllerDelegate? { get set }

    var predicate: NSPredicate? { get set }

    var sortDescriptors: [NSSortDescriptor]? { get set }

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

    var sortDescriptors: [NSSortDescriptor]? {
        get { resultsController.fetchRequest.sortDescriptors }
        set { resultsController.fetchRequest.sortDescriptors = newValue }
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        delegate?.controller(self, didChangeContentWith: snapshot)
    }
}
