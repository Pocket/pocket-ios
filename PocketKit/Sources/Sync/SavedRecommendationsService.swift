import CoreData


public class SavedRecommendationsService {
    private let space: Space

    @Published
    private(set) public var itemIDs: [String] = []

    public var slates: [Slate]? = [] {
        didSet {
            update()
        }
    }

    init(space: Space) {
        self.space = space

        NotificationCenter.default.addObserver(
            forName: NSManagedObjectContext.didSaveObjectsNotification,
            object: space.context,
            queue: .main
        ) { [weak self] _ in
            self?.update()
        }
    }

    private func update() {
        guard let slates = slates else {
            return
        }

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = SavedItem.entity()
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "item.remoteID", ascending: true)]
        request.propertiesToFetch = ["item.remoteID"]

        let recommendedItemIDs = slates.flatMap { $0.recommendations.map(\.item.id) }
        let predicate = NSPredicate(format: "%@ CONTAINS item.remoteID && isArchived = 0", recommendedItemIDs)
        request.predicate = predicate

        let results = try? space.context.fetch(request)
        let newItemIDs = results?.compactMap { result in
            (result as? [String: String])?["item.remoteID"]
        } ?? []

        if newItemIDs != itemIDs {
            itemIDs = newItemIDs
        }
    }
}
