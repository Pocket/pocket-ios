// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import CoreData
import Foundation
import PocketGraph
import SharedWithYou

public enum InitialDownloadState {
    case unknown
    case started
    case paginating(totalCount: Int, currentPercentProgress: Float)
    case completed
}

public protocol Source {
    var viewContext: NSManagedObjectContext { get }

    var events: AnyPublisher<SyncEvent, Never> { get }

    var initialSavesDownloadState: CurrentValueSubject<InitialDownloadState, Never> { get }

    var initialArchiveDownloadState: CurrentValueSubject<InitialDownloadState, Never> { get }

    func clear()

    func deleteAccount() async throws

    func makeRecentSavesController() -> NSFetchedResultsController<SavedItem>

    func makeHomeController() -> RichFetchedResultsController<Recommendation>

    func makeSavesController() -> SavedItemsController

    func makeArchiveController() -> SavedItemsController

    func makeSearchService() -> SearchService

    func makeCollectionStoriesController(slug: String) -> RichFetchedResultsController<CDCollectionStory>

    func makeImagesController() -> ImagesController

    func makeFeatureFlagsController() -> NSFetchedResultsController<FeatureFlag>

    func viewObject<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool)

    func retryImmediately()

    func favorite(item: SavedItem)

    func unfavorite(item: SavedItem)

    func delete(item: SavedItem)

    func archive(item: SavedItem)

    func unarchive(item: SavedItem)

    func addTags(item: SavedItem, tags: [String])

    func replaceTags(_ savedItem: SavedItem, tags: [String])

    func deleteTag(tag: Tag)

    func renameTag(from oldTag: Tag, to name: String)

    func retrieveTags(excluding: [String]) -> [Tag]?

    func fetchAllTags() -> [Tag]?

    func filterTags(with input: String, excluding tags: [String]) -> [Tag]?

    func fetchUnifiedHomeLineup() async throws

    func fetchCollection(by slug: String) async throws

    func fetchCollectionAuthors(by slug: String) -> [CDCollectionAuthor]

    func restore()

    func save(recommendation: Recommendation)

    func save(item: Item)

    func save(collectionStory: CDCollectionStory)

    func archive(recommendation: Recommendation)

    func archive(collectionStory: CDCollectionStory)

    func remove(recommendation: Recommendation)

    func delete(images: [Image])

    func fetchDetails(for savedItem: SavedItem) async throws -> Bool

    func fetchDetails(for item: Item) async throws -> Bool

    func save(url: String)

    func deleteHighlight(highlight: Highlight)

    func addHighlight(itemIID: NSManagedObjectID, patch: String, quote: String)

    func fetchItem(_ url: String) -> Item?

    func fetchViewContextItem(_ url: String) -> Item?

    func fetchShortUrlViewItem(_ url: String) async throws -> Item?

    func fetchViewItem(from url: String) async throws -> Item?

    func searchSaves(search: String) -> [SavedItem]?

    func fetchOrCreateSavedItem(with url: String, and remoteParts: SavedItem.RemoteSavedItem?) -> SavedItem?

    func fetchViewContextSavedItem(_ url: String) -> SavedItem?

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

    // MARK: - Feature flags

    func fetchAllFeatureFlags() async throws

    func fetchFeatureFlag(by name: String) -> FeatureFlag?

    // MARK: Shared With You
    func updateSharedWithYouItems(with urls: [String])
    func makeSharedWithYouController() -> RichFetchedResultsController<SharedWithYouItem>
    func item(by slug: String) async throws -> Item?
    func readerItem(by slug: String) async throws -> (SavedItem?, Item?)
    func requestShareUrl(_ itemUrl: String) async throws -> String?
    func deleteAllSharedWithYouItems() throws

    // MARK: ObjectID from URI Representation
    func objectID(from uri: URL) -> NSManagedObjectID?
}
