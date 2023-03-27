import Foundation
import CoreData

public protocol ImagesControllerDelegate: AnyObject {
    func controllerDidChangeContent(_ controller: ImagesController)
}

public protocol ImagesController: AnyObject {
    var delegate: ImagesControllerDelegate? { get set }

    var images: [Image]? { get }

    func performFetch() throws
}

class FetchedImagesController: NSObject, ImagesController {
    weak var delegate: ImagesControllerDelegate?

    private let resultsController: NSFetchedResultsController<Image>

    init(resultsController: NSFetchedResultsController<Image>) {
        self.resultsController = resultsController

        super.init()

        resultsController.delegate = self
    }

    var images: [Image]? {
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
