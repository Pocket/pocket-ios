import Foundation
import CoreData


public protocol ImagesControllerDelegate: AnyObject {
    func controller(
        _ controller: ImagesController,
        didChange image: Image,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    )

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
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard let image = anObject as? Image else {
            return
        }

        delegate?.controller(
            self,
            didChange: image,
            at: indexPath,
            for: type,
            newIndexPath: newIndexPath
        )
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}
