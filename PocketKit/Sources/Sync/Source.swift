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

    func makeRecentSavesController() -> NSFetchedResultsController<CDSavedItem>

    func makeHomeController() -> RichFetchedResultsController<CDRecommendation>

    func makeSavesController() -> SavedItemsController

    func makeArchiveController() -> SavedItemsController

    func makeSearchService() -> SearchService

    func makeCollectionStoriesController(slug: String) -> RichFetchedResultsController<CDCollectionStory>

    func makeImagesController() -> ImagesController

    func makeFeatureFlagsController() -> NSFetchedResultsController<CDFeatureFlag>

    func viewObject<T: NSManagedObject>(id: NSManagedObjectID) -> T?

    func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool)

    func retryImmediately()

    func favorite(item: CDSavedItem)

    func unfavorite(item: CDSavedItem)

    func delete(item: CDSavedItem)

    func archive(item: CDSavedItem)

    func unarchive(item: CDSavedItem)

    func addTags(item: CDSavedItem, tags: [String])

    func replaceTags(_ savedItem: CDSavedItem, tags: [String])

    func deleteTag(tag: CDTag)

    func renameTag(from oldTag: CDTag, to name: String)

    func retrieveTags(excluding: [String]) -> [CDTag]?

    func fetchAllTags() -> [CDTag]?

    func filterTags(with input: String, excluding tags: [String]) -> [CDTag]?

    func fetchUnifiedHomeLineup() async throws

    func fetchCollection(by slug: String) async throws

    func fetchCollectionAuthors(by slug: String) -> [CDCollectionAuthor]

    func restore()

    func save(recommendation: CDRecommendation)

    func save(item: CDItem)

    func save(collectionStory: CDCollectionStory)

    func archive(recommendation: CDRecommendation)

    func archive(collectionStory: CDCollectionStory)

    func remove(recommendation: CDRecommendation)

    func delete(images: [CDImage])

    func fetchDetails(for savedItem: CDSavedItem) async throws -> Bool

    func fetchDetails(for item: CDItem) async throws -> Bool

    func save(url: String)

    func deleteHighlight(highlight: CDHighlight)

    func addHighlight(itemIID: NSManagedObjectID, patch: String, quote: String)

    func fetchItem(_ url: String) -> CDItem?

    func fetchViewContextItem(_ url: String) -> CDItem?

    func fetchShortUrlViewItem(_ url: String) async throws -> CDItem?

    func fetchViewItem(from url: String) async throws -> CDItem?

    func searchSaves(search: String) -> [CDSavedItem]?

    func fetchOrCreateSavedItem(with url: String, and remoteParts: CDSavedItem.RemoteSavedItem?) -> CDSavedItem?

    func fetchViewContextSavedItem(_ url: String) -> CDSavedItem?

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

    func fetchFeatureFlag(by name: String) -> CDFeatureFlag?

    // MARK: Shared With You
    func updateSharedWithYouItems(with urls: [String])
    func makeSharedWithYouController() -> RichFetchedResultsController<CDSharedWithYouItem>
    func item(by slug: String) async throws -> CDItem?
    func readerItem(by slug: String) async throws -> (CDSavedItem?, CDItem?)
    func requestShareUrl(_ itemUrl: String) async throws -> String?
    func deleteAllSharedWithYouItems() throws

    // MARK: ObjectID from URI Representation
    func objectID(from uri: URL) -> NSManagedObjectID?
}
