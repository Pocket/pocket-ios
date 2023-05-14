import Combine
import CoreData
import Foundation
import SharedWithYou

public enum InitialDownloadState {
    case unknown
    case started
    case paginating(totalCount: Int, currentPercentProgress: Float)
    case completed
}

public struct PocketSWHighlight: Codable {
    var url: URL!
    var index: Int32!
    public init(url: URL!, index: Int32) {
        self.url = url
        self.index = index
    }
}

public protocol Source {
    var viewContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    var initialSavesDownloadState: CurrentValueSubject<InitialDownloadState, Never> { get }

    var initialArchiveDownloadState: CurrentValueSubject<InitialDownloadState, Never> { get }

    func clear()

    func deleteAccount() async throws

    func makeRecentSavesController() -> NSFetchedResultsController<SavedItem>

    func makeSharedWithYouHighlightsController() -> RichFetchedResultsController<SharedWithYouHighlight>

    func makeHomeController() -> RichFetchedResultsController<Recommendation>

    func makeSavesController() -> SavedItemsController

    func makeArchiveController() -> SavedItemsController

    func makeSearchService() -> SearchService

    func makeImagesController() -> ImagesController

    func viewObject<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool)

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

    func filterTags(with input: String, excluding tags: [String]) -> [Tag]?

    func fetchSlateLineup(_ identifier: String) async throws

    func restore()

    func save(recommendation: Recommendation)

    func archive(recommendation: Recommendation)

    func remove(recommendation: Recommendation)

    func delete(images: [Image])

    func fetchDetails(for savedItem: SavedItem) async throws

    func fetchDetails(for recommendation: Recommendation) async throws

    func fetchDetails(for sharedWithYouHighlight: SharedWithYouHighlight) async throws

    func save(sharedWithYouHighlight: SharedWithYouHighlight)

    func archive(sharedWithYouHighlight: SharedWithYouHighlight)

    func remove(sharedWithYouHighlight: SharedWithYouHighlight)

    /**
      Saves a new snapshot of highlights provided by SWHighlightCenter delegates.
    - parameter sharedWithYouHighlights: The highlights to replace the existing snapsnow.
    */
    func saveNewSharedWithYouSnapshot(for sharedWithYouHighlights: [PocketSWHighlight]) throws

    func save(url: URL)

    func fetchItem(_ url: URL) -> Item?

    func searchSaves(search: String) -> [SavedItem]?

    func fetchOrCreateSavedItem(with url: URL, and remoteParts: SavedItem.RemoteSavedItem?) -> SavedItem?

    /// Get the count of unread saves
    /// - Returns: Int of unread saves
    func unreadSaves() throws -> Int

    func fetchUserData() async throws

    // MARK: - Refresh Coordindator calls
    // All the following functions below this comment should be called from a RefreshCoordinator and not directtly.

    func resolveUnresolvedSavedItems(completion: (() -> Void)?)

    func refreshSaves(completion: (() -> Void)?)

    func refreshArchive(completion: (() -> Void)?)

    func refreshTags(completion: (() -> Void)?)

    // MARK: -

    func fetchAllFeatureFlags() async throws

    func fetchFeatureFlag(by name: String) -> FeatureFlag?

}
