// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData

public protocol ImagesControllerDelegate: AnyObject {
    func controllerDidChangeContent(_ controller: ImagesController)
}

public protocol ImagesController: AnyObject {
    var delegate: ImagesControllerDelegate? { get set }

    var images: [CDImage]? { get }

    func performFetch() throws
}

class FetchedImagesController: NSObject, ImagesController {
    weak var delegate: ImagesControllerDelegate?

    private let resultsController: NSFetchedResultsController<CDImage>

    init(resultsController: NSFetchedResultsController<CDImage>) {
        self.resultsController = resultsController

        super.init()

        resultsController.delegate = self
    }

    var images: [CDImage]? {
        resultsController.fetchedObjects
    }

    func performFetch() throws {
        try resultsController.performFetch()
    }
}

extension FetchedImagesController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}
