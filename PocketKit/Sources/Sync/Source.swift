import Combine
import CoreData
import Foundation


public protocol Source {
    var mainContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    func clear()

    func makeItemsController() -> SavedItemsController

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func refresh(maxItems: Int, completion: (() -> ())?)

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func unarchive(item: SavedItem)

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup?

    func fetchSlate(_ slateID: String) async throws -> Slate?

    func savedRecommendationsService() -> SavedRecommendationsService

    func save(recommendation: Slate.Recommendation)

    func archive(recommendation: Slate.Recommendation)

    func fetchArchivePage(cursor: String?, isFavorite: Bool?)

    func restore()
}

public extension Source {
    func refresh(completion: (() -> ())?) {
        self.refresh(maxItems: 400, completion: completion)
    }

    func refresh() {
        self.refresh(maxItems: 400, completion: nil)
    }
}
