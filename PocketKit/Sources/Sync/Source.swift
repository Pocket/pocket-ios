import Combine
import CoreData
import Foundation


public protocol Source {
    var mainContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    func clear()

    func makeItemsController() -> SavedItemsController

    func makeArchiveService() -> ArchiveService

    func makeSlateLineupController() -> SlateLineupController

    func makeSlateController(byID id: String) -> SlateController

    func makeUndownloadedImagesController() -> ImagesController

    func makeRecentSavesController() -> RecentSavesController

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func refresh(maxItems: Int, completion: (() -> ())?)

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func unarchive(item: SavedItem)

    func fetchSlateLineup(_ identifier: String) async throws

    func fetchSlate(_ slateID: String) async throws

    func fetchArchivePage(cursor: String?, isFavorite: Bool?)

    func restore()

    func refresh(_ object: NSManagedObject, mergeChanges: Bool)

    func resolveUnresolvedSavedItems()

    func save(recommendation: Recommendation)

    func archive(recommendation: Recommendation)

    func remove(recommendation: Recommendation)

    func download(images: [Image])

    func fetchDetails(for savedItem: SavedItem) async throws
}

public extension Source {
    func refresh(completion: (() -> ())?) {
        self.refresh(maxItems: 400, completion: completion)
    }

    func refresh() {
        self.refresh(maxItems: 400, completion: nil)
    }
}
