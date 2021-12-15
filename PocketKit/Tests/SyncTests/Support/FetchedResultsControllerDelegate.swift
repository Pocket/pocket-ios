import CoreData


class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    private let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handler()
    }
}
