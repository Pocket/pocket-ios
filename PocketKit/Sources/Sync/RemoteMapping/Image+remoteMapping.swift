import CoreData
import PocketGraph

extension Image {
    convenience init(remote: ItemParts.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }

    convenience init(remote: ItemSummary.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }
}
