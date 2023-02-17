import CoreData
import PocketGraph

extension Author {
    convenience init(remote: ItemReaderView.Author, context: NSManagedObjectContext) {
        self.init(context: context)

        id = remote.id
        name = remote.name
        url = remote.url.flatMap(URL.init)
    }

    convenience init(remote: ItemSummaryView.Author, context: NSManagedObjectContext) {
        self.init(context: context)

        id = remote.id
        name = remote.name
        url = remote.url.flatMap(URL.init)
    }
}
