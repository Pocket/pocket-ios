import CoreData
import PocketGraph

extension Image {
    convenience init(remote: ItemReaderView.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }

    convenience init(remote: ItemSummaryView.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }
}
