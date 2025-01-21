// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import UIKit

public protocol SavedItemsController: AnyObject {
    var resultsController: NSFetchedResultsController<CDSavedItem> { get }

    var predicate: NSPredicate? { get set }

    var sortDescriptors: [NSSortDescriptor]? { get set }

    var fetchedObjects: [CDSavedItem]? { get }

    func performFetch() throws

    func indexPath(forObject: CDSavedItem) -> IndexPath?
}

class FetchedSavedItemsController: NSObject, SavedItemsController {
    let resultsController: NSFetchedResultsController<CDSavedItem>

    init(resultsController: NSFetchedResultsController<CDSavedItem>) {
        self.resultsController = resultsController

        super.init()
    }

    var sortDescriptors: [NSSortDescriptor]? {
        get { resultsController.fetchRequest.sortDescriptors }
        set { resultsController.fetchRequest.sortDescriptors = newValue }
    }

    var predicate: NSPredicate? {
        get { resultsController.fetchRequest.predicate }
        set { resultsController.fetchRequest.predicate = newValue }
    }

    var fetchedObjects: [CDSavedItem]? {
        resultsController.fetchedObjects
    }

    func performFetch() throws {
        try resultsController.performFetch()
    }

    func indexPath(forObject object: CDSavedItem) -> IndexPath? {
        resultsController.indexPath(forObject: object)
    }
}
