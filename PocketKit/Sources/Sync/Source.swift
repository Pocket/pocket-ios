import Combine
import CoreData
import Foundation

public enum InitialDownloadState {
    case unknown
    case started
    case paginating(totalCount: Int)
    case completed
}

public protocol Source {
    var mainContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    var initialDownloadState: CurrentValueSubject<InitialDownloadState, Never> { get }

    func clear()

    func makeItemsController() -> SavedItemsController

    func makeArchiveService() -> ArchiveService

    func makeSearchService() -> SearchService

    func makeUndownloadedImagesController() -> ImagesController

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func refresh(maxItems: Int, completion: (() -> Void)?)

    func retryImmediately()

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func unarchive(item: SavedItem)

    func addTags(item: SavedItem, tags: [String])

    func deleteTag(tag: Tag)

    func renameTag(from oldTag: Tag, to name: String)

    func retrieveTags(excluding: [String]) -> [Tag]?

    func fetchAllTags() -> [Tag]?

    func fetchTags(isArchived: Bool) -> [Tag]?

    func fetchSlateLineup(_ identifier: String) async throws

    func fetchSlate(_ slateID: String) async throws

    func restore()

    func refresh(_ object: NSManagedObject, mergeChanges: Bool)

    func resolveUnresolvedSavedItems()

    func save(recommendation: Recommendation)

    func archive(recommendation: Recommendation)

    func remove(recommendation: Recommendation)

    func download(images: [Image])

    func fetchDetails(for savedItem: SavedItem) async throws

    func fetchDetails(for recommendation: Recommendation) async throws

    func save(url: URL)

    func fetchItem(_ url: URL) -> Item?

    func searchSaves(search: String) -> [SavedItem]?
}

public extension Source {
    func refresh(completion: (() -> Void)?) {
        self.refresh(maxItems: 400, completion: completion)
    }

    func refresh() {
        self.refresh(maxItems: 400, completion: nil)
    }
}
