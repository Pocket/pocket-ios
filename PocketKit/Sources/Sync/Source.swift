import Combine
import CoreData
import Foundation


public protocol Source {
    var mainContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    func clear()

    func makeItemsController() -> SavedItemsController

    func makeArchivedItemsController() -> SavedItemsController

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func refresh(maxItems: Int, completion: (() -> ())?)

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func unarchive(item: SavedItem)

    func fetchSlateLineup(_ identifier: String) async throws

    func fetchSlate(_ slateID: String) async throws

    func savedRecommendationsService() -> SavedRecommendationsService

    func save(recommendation: UnmanagedSlate.UnmanagedRecommendation)

    func archive(recommendation: UnmanagedSlate.UnmanagedRecommendation)

    func fetchArchivePage(cursor: String?, isFavorite: Bool?)

    func restore()

    func refresh(_ object: NSManagedObject, mergeChanges: Bool)

    func resolveUnresolvedSavedItems()
}

public extension Source {
    func refresh(completion: (() -> ())?) {
        self.refresh(maxItems: 400, completion: completion)
    }

    func refresh() {
        self.refresh(maxItems: 400, completion: nil)
    }
}
