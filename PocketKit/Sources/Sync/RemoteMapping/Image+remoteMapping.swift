import CoreData


extension Image {
    convenience init(remote: ItemParts.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }
}
