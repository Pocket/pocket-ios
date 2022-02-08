import CoreData
import Foundation


public protocol Source {
    var mainContext: NSManagedObjectContext { get }

    func clear()

    func makeItemsController() -> NSFetchedResultsController<SavedItem>

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func refresh(maxItems: Int, completion: (() -> ())?)

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup?

    func fetchSlate(_ slateID: String) async throws -> Slate?

    func savedRecommendationsService() -> SavedRecommendationsService

    func save(recommendation: Slate.Recommendation)

    func archive(recommendation: Slate.Recommendation)

    func fetchArchivedItems(isFavorite: Bool) async throws -> [ArchivedItem]

    func delete(item: ArchivedItem) async throws

    func favorite(item: ArchivedItem) async throws

    func unfavorite(item: ArchivedItem) async throws

    func reAdd(item: ArchivedItem) async throws
}

public extension Source {
    func refresh(completion: (() -> ())?) {
        self.refresh(maxItems: 400, completion: completion)
    }

    func refresh() {
        self.refresh(maxItems: 400, completion: nil)
    }
    
    func fetchArchivedItems() async throws -> [ArchivedItem] {
        try await fetchArchivedItems(isFavorite: false)
    }
}
