// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import CoreData
import Combine

class MockSource: Source {
    func save(item: Sync.Item) {
    }

    func fetchDetails(for item: Sync.Item) async throws -> Bool {
        true
    }

    func fetchViewItem(from url: String) async throws -> Sync.Item? {
        nil
    }

    func fetchViewContextItem(_ url: String) -> Sync.Item? {
        return nil
    }

    func save(collectionStory: Sync.CollectionStory) {
    }

    func archive(collectionStory: Sync.CollectionStory) {
    }

    var _events: SyncEvents = SyncEvents()
    var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    var initialSavesDownloadState: CurrentValueSubject<InitialDownloadState, Never> = .init(.unknown)
    var initialArchiveDownloadState: CurrentValueSubject<Sync.InitialDownloadState, Never> = .init(.unknown)

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    private var _viewContext: NSManagedObjectContext?
    var viewContext: NSManagedObjectContext {
        get {
            guard let context = _viewContext else {
                fatalError()
            }
            return context
        }
        set { _viewContext = newValue }
    }

    func clear() {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func restore() {
        fatalError("\(Self.self).\(#function) is not implemented")
    }
}

extension MockSource {
    private static let backgroundObject = "backgroundObject"
    typealias BackgroundObjectImpl = (NSManagedObjectID) -> NSManagedObject?

    struct BackgroundObjectCall {
        let id: NSManagedObjectID
    }

    func stubBackgroundObject(_ impl: @escaping BackgroundObjectImpl) {
        implementations[Self.backgroundObject] = impl
    }

    func backgroundObject<T>(id: NSManagedObjectID) -> T? where T: NSManagedObject {
        guard let impl = implementations[Self.backgroundObject] as? BackgroundObjectImpl else {
            fatalError("\(Self.self)#\(#function) is not implemented")
        }

        calls[Self.backgroundObject] = (calls[Self.backgroundObject] ?? []) + [BackgroundObjectCall(id: id)]

        return impl(id) as? T
    }
}

// MARK: - proxy view object to space
extension MockSource {
    private static let viewObject = "viewObject"
    typealias ViewObjectImpl = (NSManagedObjectID) -> NSManagedObject?

    struct ViewObjectCall {
        let id: NSManagedObjectID
    }

    func stubViewObject(impl: @escaping ViewObjectImpl) {
        implementations[Self.viewObject] = impl
    }

    func viewObject<T>(id: NSManagedObjectID) -> T? where T: NSManagedObject {
        guard let impl = implementations[Self.viewObject] as? ViewObjectImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.viewObject] = (calls[Self.viewObject] ?? []) + [ViewObjectCall(id: id)]
        return impl(id) as? T
    }

    func fetchViewObject(at index: Int) -> ViewObjectCall? {
        guard let calls = calls[Self.viewObject],
              calls.count > index else {
            return nil
        }

        return calls[index] as? ViewObjectCall
    }
}

// MARK: - Refresh Saves
extension MockSource {
    private static let refreshSaves = "refreshSaves"
    typealias RefreshSavesImpl = ((() -> Void)?) -> Void

    struct RefreshSavesCall {
        let completion: (() -> Void)?
    }

    func stubRefreshSaves(impl: @escaping RefreshSavesImpl) {
        implementations[Self.refreshSaves] = impl
    }

    func refreshSaves(completion: (() -> Void)?) {
        guard let impl = implementations[Self.refreshSaves] as? RefreshSavesImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.refreshSaves] = (calls[Self.refreshSaves] ?? []) + [
            RefreshSavesCall(completion: completion)
        ]

        impl(completion)
    }

    func refreshSavesCall(at index: Int) -> RefreshSavesCall? {
        guard let calls = calls[Self.refreshSaves], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshSavesCall
    }
}

// MARK: - Refresh Archive
extension MockSource {
    private static let refreshArchive = "refreshArchive"
    typealias RefreshArchiveImpl = ((() -> Void)?) -> Void

    struct RefreshArchiveCall {
        let completion: (() -> Void)?
    }

    func stubRefreshArchive(impl: @escaping RefreshArchiveImpl) {
        implementations[Self.refreshArchive] = impl
    }

    func refreshArchive(completion: (() -> Void)?) {
        guard let impl = implementations[Self.refreshArchive] as? RefreshArchiveImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.refreshArchive] = (calls[Self.refreshArchive] ?? []) + [
            RefreshArchiveCall(completion: completion)
        ]

        impl(completion)
    }

    func refreshArchiveCall(at index: Int) -> RefreshArchiveCall? {
        guard let calls = calls[Self.refreshArchive], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshArchiveCall
    }
}

// MARK: - Make items controller
extension MockSource {
    static let makeSavesController = "makeSavesController"
    typealias MakeSavesControllerImpl = () -> SavedItemsController

    struct MakeSavesControllerCall {
    }

    func stubMakeSavesController(impl: @escaping MakeSavesControllerImpl) {
        implementations[Self.makeSavesController] = impl
    }

    func makeSavesController() -> SavedItemsController {
        guard let impl = implementations[Self.makeSavesController] as? MakeSavesControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeSavesController] = (calls[Self.makeSavesController] ?? []) + [MakeSavesControllerCall()]

        return impl()
    }

    func makeSavesControllerCall(at index: Int) -> MakeSavesControllerCall? {
        guard let calls = calls[Self.makeSavesController], calls.count > index else {
            return nil
        }

        return calls[index] as? MakeSavesControllerCall
    }
}

// MARK: - Make recent saves controller
extension MockSource {
    static let makeRecentSavesController = "makeRecentSavesController"
    typealias MakeRecentSavesControllerImpl = () -> NSFetchedResultsController<Sync.SavedItem>

    struct MakeRecentSavesControllerCall {
    }

    func stubMakeRecentSavesController(impl: @escaping MakeRecentSavesControllerImpl) {
        implementations[Self.makeRecentSavesController] = impl
    }

    func makeRecentSavesController() -> NSFetchedResultsController<Sync.SavedItem> {
        guard let impl = implementations[Self.makeRecentSavesController] as? MakeRecentSavesControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeRecentSavesController] = (calls[Self.makeRecentSavesController] ?? []) + [MakeRecentSavesControllerCall()]

        return impl()
    }

    func makeRecentSavesControllerCall(at index: Int) -> MakeRecentSavesControllerCall? {
        guard let calls = calls[Self.makeRecentSavesController], calls.count > index else {
            return nil
        }

        return calls[index] as? MakeRecentSavesControllerCall
    }
}

// MARK: - Make collection stories controller
extension MockSource {
    private static let makeCollectionStoriesController = "makeCollectionStoriesController"
    typealias MakeCollectionStoriesControllerImpl = () -> RichFetchedResultsController<Sync.CollectionStory>

    struct MakeCollectionStoriesControllerCall {}

    func stubMakeCollectionStoriesController(impl: @escaping MakeCollectionStoriesControllerImpl) {
        implementations[Self.makeCollectionStoriesController] = impl
    }

    func makeCollectionStoriesController(slug: String) -> Sync.RichFetchedResultsController<Sync.CollectionStory> {
        guard let impl = implementations[Self.makeCollectionStoriesController] as? MakeCollectionStoriesControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeCollectionStoriesController] = (calls[Self.makeCollectionStoriesController] ?? []) + [MakeCollectionStoriesControllerCall()]

        return impl()
    }
}

// MARK: fetch collection authors
extension MockSource {
    private static let fetchCollectionAuthors = "fetchCollectionAuthors"
    typealias FetchCollectionAuthorsImpl = (String) -> [Sync.CollectionAuthor]

    struct FetchCollectionAuthorsCall {}

    func stubFetchCollectionAuthors(impl: @escaping FetchCollectionAuthorsImpl) {
        implementations[Self.fetchCollectionAuthors] = impl
    }

    func fetchCollectionAuthors(by slug: String) -> [Sync.CollectionAuthor] {
        guard let impl = implementations[Self.fetchCollectionAuthors] as? FetchCollectionAuthorsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }
        calls[Self.fetchCollectionAuthors] = (calls[Self.fetchCollectionAuthors] ?? []) + [FetchCollectionAuthorsCall()]
        return impl(slug)
    }
}

// MARK: - Make home controller
extension MockSource {
    static let makeHomeController = "makeHomeController"
    typealias MakeHomeControllerImpl = () -> RichFetchedResultsController<Sync.Recommendation>

    struct MakeHomeControllerCall {
    }

    func stubMakeHomeController(impl: @escaping MakeHomeControllerImpl) {
        implementations[Self.makeHomeController] = impl
    }

    func makeHomeController() -> RichFetchedResultsController<Sync.Recommendation> {
        guard let impl = implementations[Self.makeHomeController] as? MakeHomeControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeHomeController] = (calls[Self.makeHomeController] ?? []) + [MakeHomeControllerCall()]

        return impl()
    }

    func makeHomeControllerCall(at index: Int) -> MakeHomeControllerCall? {
        guard let calls = calls[Self.makeHomeController], calls.count > index else {
            return nil
        }

        return calls[index] as? MakeHomeControllerCall
    }
}

// MARK: - Make archive controller
extension MockSource {
    static let makeArchiveController = "makeArchiveController"
    typealias MakeArchiveControllerImpl = () -> SavedItemsController

    struct MakeArchiveControllerCall {
    }

    func stubMakeArchiveController(impl: @escaping MakeArchiveControllerImpl) {
        implementations[Self.makeArchiveController] = impl
    }

    func makeArchiveController() -> SavedItemsController {
        guard let impl = implementations[Self.makeArchiveController] as? MakeArchiveControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeArchiveController] = (calls[Self.makeArchiveController] ?? []) + [MakeArchiveControllerCall()]

        return impl()
    }

    func makeArchiveControllerCall(at index: Int) -> MakeArchiveControllerCall? {
        guard let calls = calls[Self.makeArchiveController], calls.count > index else {
            return nil
        }

        return calls[index] as? MakeArchiveControllerCall
    }
}

// MARK: - Make feature flags controller
extension MockSource {
    static let makeFeatureFlagsController = "makeFeatureFlagController"
    typealias MakeFeatureFlagsControllerImpl = () -> NSFetchedResultsController<FeatureFlag>

    struct MakeFeatureFlagsControllerCall {
    }

    func stubMakeFeatureFlagsController(impl: @escaping MakeFeatureFlagsControllerImpl) {
        implementations[Self.makeFeatureFlagsController] = impl
    }

    func makeFeatureFlagsController() -> NSFetchedResultsController<FeatureFlag> {
        guard let impl = implementations[Self.makeFeatureFlagsController] as? MakeFeatureFlagsControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeFeatureFlagsController] = (calls[Self.makeFeatureFlagsController] ?? []) + [MakeFeatureFlagsControllerCall()]

        return impl()
    }

    func makeFeatureFlagsControllerCall(at index: Int) -> MakeFeatureFlagsControllerCall? {
        guard let calls = calls[Self.makeFeatureFlagsController], calls.count > index else {
            return nil
        }

        return calls[index] as? MakeFeatureFlagsControllerCall
    }
}

// MARK: - Make search service
extension MockSource {
    static let makeSearchService = "makeSearchService"
    typealias MakeSearchServiceImpl = () -> SearchService

    struct MakeSearchServiceCall { }

    func stubMakeSearchService(impl: @escaping MakeSearchServiceImpl) {
        implementations[Self.makeSearchService] = impl
    }

    func makeSearchService() -> SearchService {
        guard let impl = implementations[Self.makeSearchService] as? MakeSearchServiceImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeSearchService] = (calls[Self.makeSearchService] ?? []) + [MakeSearchServiceCall()]

        return impl()
    }
}

// MARK: - Make images controller
extension MockSource {
    static let makeImagesController = "makeImagesController"
    typealias MakeImagesControllerImpl = () -> ImagesController

    func stubMakeImagesController(impl: @escaping MakeImagesControllerImpl) {
        implementations[Self.makeImagesController] = impl
    }

    func makeImagesController() -> ImagesController {
        guard let impl = implementations[Self.makeImagesController] as? MakeImagesControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl()
    }
}

// MARK: - Fetch Archived content
extension MockSource {
    static let fetchArchivePage = "fetchArchivePage"
    typealias FetchArchivePageImpl = (String?, Bool?) -> Void

    struct FetchArchivePageCall {
        let cursor: String?
        let isFavorite: Bool?
    }

    func stubFetchArchivePage(impl: @escaping FetchArchivePageImpl) {
        implementations[Self.fetchArchivePage] = impl
    }

    func fetchArchivePage(cursor: String?, isFavorite: Bool?) {
        guard let impl = implementations[Self.fetchArchivePage] as? FetchArchivePageImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchArchivePage] = (calls[Self.fetchArchivePage] ?? []) + [
            FetchArchivePageCall(cursor: cursor, isFavorite: isFavorite)
        ]

        return impl(cursor, isFavorite)
    }

    func fetchArchivePageCall(at index: Int) -> FetchArchivePageCall? {
        guard let calls = calls[Self.fetchArchivePage], index < calls.count else {
            return nil
        }

        return calls[index] as? FetchArchivePageCall
    }
}

// MARK: - Delete an item
extension MockSource {
    static let deleteSavedItem = "deleteSavedItem"
    typealias DeleteSavedItemImpl = (SavedItem) -> Void
    struct DeleteSavedItemCall {
        let item: SavedItem
    }

    func stubDeleteSavedItem(impl: @escaping DeleteSavedItemImpl) {
        implementations[Self.deleteSavedItem] = impl
    }

    func delete(item: SavedItem) {
        guard let impl = implementations[Self.deleteSavedItem] as? DeleteSavedItemImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.deleteSavedItem] = (calls[Self.deleteSavedItem] ?? []) + [
            DeleteSavedItemCall(item: item)
        ]

        impl(item)
    }

    func deleteSavedItemCall(at index: Int) -> DeleteSavedItemCall? {
        guard let calls = calls[Self.deleteSavedItem],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? DeleteSavedItemCall
    }
}

// MARK: - Add Tags to an item
extension MockSource {
    static let addTagsToSavedItem = "addTagsToSavedItem"
    typealias AddTagsSavedItemImpl = (SavedItem, [String]) -> Void
    struct AddTagsSavedItemCall {
        let item: SavedItem
        let tags: [String]
    }

    func stubAddTagsSavedItem(impl: @escaping AddTagsSavedItemImpl) {
        implementations[Self.addTagsToSavedItem] = impl
    }

    func addTags(item: SavedItem, tags: [String]) {
        guard let impl = implementations[Self.addTagsToSavedItem] as? AddTagsSavedItemImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.addTagsToSavedItem] = (calls[Self.addTagsToSavedItem] ?? []) + [
            AddTagsSavedItemCall(item: item, tags: tags)
        ]

        impl(item, tags)
    }

    func addTagsToSavedItemCall(at index: Int) -> AddTagsSavedItemCall? {
        guard let calls = calls[Self.addTagsToSavedItem],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? AddTagsSavedItemCall
    }
}

// MARK: - Retrieve Tags
extension MockSource {
    static let retrieveTags = "retrieveTags"
    typealias RetrieveTagsImpl = ([String]) -> [Tag]?
    struct RetrieveTagsImplCall {
        let tags: [String]
    }

    func stubRetrieveTags(impl: @escaping RetrieveTagsImpl) {
        implementations[Self.retrieveTags] = impl
    }

    func retrieveTags(excluding tags: [String]) -> [Tag]? {
        guard let impl = implementations[Self.retrieveTags] as? RetrieveTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.retrieveTags] = (calls[Self.retrieveTags] ?? []) + [
            RetrieveTagsImplCall(tags: tags)
        ]

        return impl(tags)
    }

    func retrieveTagsCall(at index: Int) -> RetrieveTagsImplCall? {
        guard let calls = calls[Self.retrieveTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? RetrieveTagsImplCall
    }
}

// MARK: - Filter Tags
extension MockSource {
    private static let filterTags = "filterTags"
    typealias FilterTagsImpl = ([String]) -> [Tag]?

    struct FilterTagsImplCall {
        let tags: [String]
    }

    func stubFilterTags(impl: @escaping FilterTagsImpl) {
        implementations[Self.filterTags] = impl
    }

    func filterTags(with text: String, excluding tags: [String]) -> [Tag]? {
        guard let impl = implementations[Self.filterTags] as? FilterTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.filterTags] = (calls[Self.filterTags] ?? []) + [
            RetrieveTagsImplCall(tags: tags)
        ]

        return impl(tags)
    }

    func filterTagsCall(at index: Int) -> FilterTagsImplCall? {
        guard let calls = calls[Self.filterTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? FilterTagsImplCall
    }
}

// MARK: - Fetch Tags
extension MockSource {
    static let fetchTags = "fetchTags"
    typealias FetchTagsImpl = () -> [Tag]?
    struct FetchTagsImplCall { }

    func stubFetchTags(impl: @escaping FetchTagsImpl) {
        implementations[Self.fetchTags] = impl
    }

    func fetchTags(isArchived: Bool = false) -> [Tag]? {
        guard let impl = implementations[Self.fetchTags] as? FetchTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchTags] = (calls[Self.fetchTags] ?? []) + [
            FetchTagsImplCall()
        ]

        return impl()
    }

    func fetchTagsCall(at index: Int) -> FetchTagsImplCall? {
        guard let calls = calls[Self.fetchTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? FetchTagsImplCall
    }
}

// MARK: - Delete Account
extension MockSource {
    static let deleteAccount = "deleteAccount"
    typealias DeleteAccountImpl = () -> Void
    struct DeleteAccountCall { }

    func stubDeleteAccount(impl: @escaping DeleteAccountImpl) {
        implementations[Self.deleteAccount] = impl
    }

    func deleteAccount() async throws {
        guard let impl = implementations[Self.deleteAccount] as? DeleteAccountImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.deleteAccount] = (calls[Self.deleteAccount] ?? []) + [
            DeleteAccountCall()
        ]

        return impl()
    }

    func deleteAccountCall(at index: Int) -> DeleteAccountCall? {
        guard let calls = calls[Self.deleteAccount],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? DeleteAccountCall
    }
}

// MARK: - Fetch All Tags
extension MockSource {
    static let fetchAllTags = "fetchAllTags"
    typealias FetchAllTagsImpl = () -> [Tag]?
    struct FetchAllTagsCall { }

    func stubFetchAllTags(impl: @escaping FetchAllTagsImpl) {
        implementations[Self.fetchAllTags] = impl
    }

    func fetchAllTags() -> [Tag]? {
        guard let impl = implementations[Self.fetchAllTags] as? FetchAllTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchAllTags] = (calls[Self.fetchAllTags] ?? []) + [
            FetchAllTagsCall()
        ]

        return impl()
    }

    func fetchTagsCall(at index: Int) -> FetchAllTagsCall? {
        guard let calls = calls[Self.fetchAllTags],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? FetchAllTagsCall
    }
}

// MARK: - Delete Tag
extension MockSource {
    static let deleteTag = "deleteTag"
    typealias DeleteTagImpl = (Tag) -> Void
    struct DeleteTagImplCall {
        let tag: Tag
    }

    func stubDeleteTag(impl: @escaping DeleteTagImpl) {
        implementations[Self.deleteTag] = impl
    }

    func deleteTag(tag: Tag) {
        guard let impl = implementations[Self.deleteTag] as? DeleteTagImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.deleteTag] = (calls[Self.deleteTag] ?? []) + [
            DeleteTagImplCall(tag: tag)
        ]

        return impl(tag)
    }

    func deleteTagCall(at index: Int) -> DeleteTagImplCall? {
        guard let calls = calls[Self.deleteTag],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? DeleteTagImplCall
    }
}

// MARK: - Rename Tags
extension MockSource {
    static let renameTag = "renameTag"
    typealias RenameTagImpl = (Tag, String) -> Void
    struct RenameTagsImplCall {
        let oldTag: Tag
        let name: String
    }

    func stubRenameTag(impl: @escaping RenameTagImpl) {
        implementations[Self.renameTag] = impl
    }

    func renameTag(from oldTag: Tag, to name: String) {
        guard let impl = implementations[Self.renameTag] as? RenameTagImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.renameTag] = (calls[Self.renameTag] ?? []) + [
            RenameTagsImplCall(oldTag: oldTag, name: name)
        ]

        return impl(oldTag, name)
    }

    func renameTagCall(at index: Int) -> RenameTagsImplCall? {
        guard let calls = calls[Self.renameTag],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? RenameTagsImplCall
    }
}

// MARK: - Favorite an item
extension MockSource {
    static let favoriteSavedItem = "favoriteSavedItem"
    typealias FavoriteSavedItemImpl = (SavedItem) -> Void
    struct FavoriteSavedItemCall {
        let item: SavedItem
    }

    func stubFavoriteSavedItem(impl: @escaping FavoriteSavedItemImpl) {
        implementations[Self.favoriteSavedItem] = impl
    }

    func favorite(item: SavedItem) {
        guard let impl = implementations[Self.favoriteSavedItem] as? FavoriteSavedItemImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.favoriteSavedItem] = (calls[Self.favoriteSavedItem] ?? []) + [
            FavoriteSavedItemCall(item: item)
        ]

        impl(item)
    }

    func favoriteSavedItemCall(at index: Int) -> FavoriteSavedItemCall? {
        guard let calls = calls[Self.favoriteSavedItem],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? FavoriteSavedItemCall
    }
}

// MARK: - Unfavorite an item
extension MockSource {
    static let unfavoriteSavedItem = "unfavoriteSavedItem"
    typealias UnfavoriteSavedItemImpl = (SavedItem) -> Void
    struct UnfavoriteSavedItemCall {
        let item: SavedItem
    }

    func stubUnfavoriteSavedItem(impl: @escaping UnfavoriteSavedItemImpl) {
        implementations[Self.unfavoriteSavedItem] = impl
    }

    func unfavorite(item: SavedItem) {
        guard let impl = implementations[Self.unfavoriteSavedItem] as? UnfavoriteSavedItemImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.unfavoriteSavedItem] = (calls[Self.unfavoriteSavedItem] ?? []) + [
            UnfavoriteSavedItemCall(item: item)
        ]

        impl(item)
    }

    func unfavoriteSavedItemCall(at index: Int) -> UnfavoriteSavedItemCall? {
        guard let calls = calls[Self.unfavoriteSavedItem],
              calls.count > index else {
                  return nil
              }

        return calls[index] as? UnfavoriteSavedItemCall
    }
}

// MARK: - Unarchive an item
extension MockSource {
    static let unarchiveSavedItem = "unarchiveSavedItem"
    typealias UnarchiveSavedItemImpl = (SavedItem) -> Void
    struct UnarchiveSavedItemCall {
        let item: SavedItem
    }

    func stubUnarchiveSavedItem(impl: @escaping UnarchiveSavedItemImpl) {
        implementations[Self.unarchiveSavedItem] = impl
    }

    func unarchive(item: SavedItem) {
        guard let impl = implementations[Self.unarchiveSavedItem] as? UnarchiveSavedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.unarchiveSavedItem] = (calls[Self.unarchiveSavedItem] ?? []) + [
            UnarchiveSavedItemCall(item: item)
        ]

        impl(item)
    }
}

// MARK: - Archive an item
extension MockSource {
    static let archiveSavedItem = "archiveSavedItem"
    typealias ArchiveSavedItemImpl = (SavedItem) -> Void
    struct ArchiveSavedItemCall {
        let item: SavedItem
    }

    func stubArchiveSavedItem(impl: @escaping ArchiveSavedItemImpl) {
        implementations[Self.archiveSavedItem] = impl
    }

    func archive(item: SavedItem) {
        guard let impl = implementations[Self.archiveSavedItem] as? ArchiveSavedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.archiveSavedItem] = (calls[Self.archiveSavedItem] ?? []) + [
            ArchiveSavedItemCall(item: item)
        ]

        impl(item)
    }
}

// MARK: - background Refresh an object
extension MockSource {
    static let backgroundRefreshObject = "backgroundRefreshObject"
    typealias BackgroundRefreshObjectImpl = (NSManagedObject, Bool) -> Void
    struct BackgroundRefreshObjectCall {
        let object: NSManagedObject
        let mergeChanges: Bool
    }

    func stubBackgroundRefreshObject(impl: @escaping BackgroundRefreshObjectImpl) {
        implementations[Self.backgroundRefreshObject] = impl
    }

    func backgroundRefresh(_ object: NSManagedObject, mergeChanges: Bool) {
        guard let impl = implementations[Self.backgroundRefreshObject] as? BackgroundRefreshObjectImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.backgroundRefreshObject] = (calls[Self.backgroundRefreshObject] ?? []) + [
            BackgroundRefreshObjectCall(object: object, mergeChanges: mergeChanges)
        ]

        impl(object, mergeChanges)
    }

    func backgroundRefreshObjectCall(at index: Int) -> BackgroundRefreshObjectCall? {
        guard let calls = calls[Self.backgroundRefreshObject], calls.count > index else {
            return nil
        }

        return calls[index] as? BackgroundRefreshObjectCall
    }
}

// MARK: - Resolved unresolved saved items
extension MockSource {
    static let resolveUnresolvedSavedItems = "resolveUnresolvedSavedItems"
    typealias ResolveUnresolvedSavedItemsImpl = ((() -> Void)?) -> Void

    struct ResolveUnresolvedSavedItemsCall {
        let completion: (() -> Void)?
    }

    func stubResolveUnresolvedSavedItems(impl: @escaping ResolveUnresolvedSavedItemsImpl) {
        implementations[Self.resolveUnresolvedSavedItems] = impl
    }

    func resolveUnresolvedSavedItems(completion: (() -> Void)?) {
        guard let impl = implementations[Self.resolveUnresolvedSavedItems] as? ResolveUnresolvedSavedItemsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.resolveUnresolvedSavedItems] = (calls[Self.resolveUnresolvedSavedItems] ?? []) + [
            ResolveUnresolvedSavedItemsCall(completion: completion)
        ]

        impl(completion)
    }

    func resolveUnresolvedSavedItemsCall(at index: Int) -> ResolveUnresolvedSavedItemsCall? {
        guard let calls = calls[Self.resolveUnresolvedSavedItems],
              calls.count > index else {
            return nil
        }

        return calls[index] as? ResolveUnresolvedSavedItemsCall
    }
}

// MARK: - Slate(Lineup)

extension MockSource {
    static let fetchSlateLineup = "fetchSlateLineup"
    typealias FetchSlateLineupImpl = (String) -> Void
    struct FetchSlateLineupCall {
        let identifier: String
    }

    func stubFetchSlateLineup(_ impl: @escaping FetchSlateLineupImpl) {
        implementations[Self.fetchSlateLineup] = impl
    }

    func fetchSlateLineupCall(at index: Int) -> FetchSlateLineupCall? {
        guard let calls = calls[Self.fetchSlateLineup],
              index < calls.count,
              let call = calls[index] as? FetchSlateLineupCall else {
                  return nil
              }

        return call
    }

    func fetchUnifiedHomeLineup() async throws {
        guard let impl = implementations[Self.fetchSlateLineup] as? FetchSlateLineupImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchSlateLineup] = (calls[Self.fetchSlateLineup] ?? []) + [
            FetchSlateLineupCall(identifier: "")
        ]

        impl("")
    }
}

// MARK: - Recommendations
extension MockSource {
    static let saveRecommendation = "saveRecommendation"
    typealias SaveRecommendationImpl = (Recommendation) -> Void
    struct SaveRecommendationCall {
        let recommendation: Recommendation
    }

    static let archiveRecommendation = "archiveRecommendation"
    typealias ArchiveRecommendationImpl = (Recommendation) -> Void
    struct ArchiveRecommendationCall {
        let recommendation: Recommendation
    }

    static let removeRecommendation = "removeRecommendation"
    typealias RemoveRecommendationImpl = (Recommendation) -> Void
    struct RemoveRecommendationCall {
        let recommendation: Recommendation
    }

    func stubSaveRecommendation(_ impl: @escaping SaveRecommendationImpl) {
        implementations[Self.saveRecommendation] = impl
    }

    func saveRecommendationCall(at index: Int) -> SaveRecommendationCall? {
        guard let calls = calls[Self.saveRecommendation],
              index < calls.count,
              let call = calls[index] as? SaveRecommendationCall else {
                  return nil
              }

        return call
    }

    func save(recommendation: Recommendation) {
        guard let impl = implementations[Self.saveRecommendation] as? SaveRecommendationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.saveRecommendation] = (calls[Self.saveRecommendation] ?? []) + [
            SaveRecommendationCall(recommendation: recommendation)
        ]

        impl(recommendation)
    }

    func stubArchiveRecommendation(_ impl: @escaping ArchiveRecommendationImpl) {
        implementations[Self.archiveRecommendation] = impl
    }

    func archiveRecommendationCall(at index: Int) -> ArchiveRecommendationCall? {
        guard let calls = calls[Self.archiveRecommendation],
              index < calls.count,
              let call = calls[index] as? ArchiveRecommendationCall else {
                  return nil
              }

        return call
    }

    func archive(recommendation: Recommendation) {
        guard let impl = implementations[Self.archiveRecommendation] as? ArchiveRecommendationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.archiveRecommendation] = (calls[Self.archiveRecommendation] ?? []) + [
            ArchiveRecommendationCall(recommendation: recommendation)
        ]

        impl(recommendation)
    }

    func stubRemoveRecommendation(_ impl: @escaping RemoveRecommendationImpl) {
        implementations[Self.removeRecommendation] = impl
    }

    func removeRecommendationCall(at index: Int) -> RemoveRecommendationCall? {
        guard let calls = calls[Self.removeRecommendation],
              index < calls.count,
              let call = calls[index] as? RemoveRecommendationCall else {
                  return nil
              }

        return call
    }

    func remove(recommendation: Recommendation) {
        guard let impl = implementations[Self.removeRecommendation] as? RemoveRecommendationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.removeRecommendation] = (calls[Self.removeRecommendation] ?? []) + [
            RemoveRecommendationCall(recommendation: recommendation)
        ]

        impl(recommendation)
    }
}

extension MockSource {
    private static let deleteImages = "deleteImages"
    typealias DeleteImagesImpl = ([Image]) -> Void
    struct DeleteImagesCall {
        let images: [Image]
    }

    func stubDeleteImages(_ impl: @escaping DeleteImagesImpl) {
        implementations[Self.deleteImages] = impl
    }

    func deleteImagesCall(at index: Int) -> DeleteImagesCall? {
        guard let calls = calls[Self.deleteImages],
              index < calls.count,
              let call = calls[index] as? DeleteImagesCall else {
            return nil
        }

        return call
    }

    func delete(images: [Image]) {
        guard let impl = implementations[Self.deleteImages] as? DeleteImagesImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.deleteImages] = (calls[Self.deleteImages] ?? []) + [
            DeleteImagesCall(images: images)
        ]

        impl(images)
    }
}

// MARK: - Fetch details
extension MockSource {
    static let fetchDetails = "fetchDetails"
    typealias FetchDetailsImpl = (SavedItem) async throws -> Bool

    struct FetchDetailsCall {
        let savedItem: SavedItem
    }

    func stubFetchDetails(impl: @escaping FetchDetailsImpl) {
        implementations[Self.fetchDetails] = impl
    }

    func fetchDetails(for savedItem: SavedItem) async throws -> Bool {
        guard let impl = implementations[Self.fetchDetails] as? FetchDetailsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchDetails] = (calls[Self.fetchDetails] ?? []) + [FetchDetailsCall(savedItem: savedItem)]
        print("Calling impl: \(Date().timeIntervalSince1970)")
        return try await impl(savedItem)
    }

    func fetchDetailsCall(at index: Int) -> FetchDetailsCall? {
        guard let calls = calls[Self.fetchDetails],
              calls.count > index else {
            return nil
        }

        return calls[index] as? FetchDetailsCall
    }
}

// MARK: - Save URL
extension MockSource {
    private static let saveURL = "saveURL"
    typealias SaveURLImpl = (String) -> Void
    struct SaveURLCall {
        let url: String
    }

    func stubSaveURL(_ impl: @escaping SaveURLImpl) {
        implementations[Self.saveURL] = impl
    }

    func saveURLCall(at index: Int) -> SaveURLCall? {
        guard let calls = calls[Self.saveURL],
              index < calls.count,
              let call = calls[index] as? SaveURLCall else {
            return nil
        }

        return call
    }

    func save(url: String) {
        guard let impl = implementations[Self.saveURL] as? SaveURLImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.saveURL] = (calls[Self.saveURL] ?? []) + [
            SaveURLCall(url: url)
        ]

        impl(url)
    }
}

// MARK: - Retry Immediately
extension MockSource {
    static let retryImmediately = "retryImmediately"
    typealias RetryImmediatelyImpl = () -> Void

    struct RetryImmediatelyCall { }

    func stubRetryImmediately(impl: @escaping RetryImmediatelyImpl) {
        implementations[Self.retryImmediately] = impl
    }

    func retryImmediately() {
        guard let impl = implementations[Self.retryImmediately] as? RetryImmediatelyImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.retryImmediately] = (calls[Self.retryImmediately] ?? []) + [RetryImmediatelyCall()]
        print("Calling impl: \(Date().timeIntervalSince1970)")
        return impl()
    }

    func retryImmediatelyCall(at index: Int) -> RetryImmediatelyCall? {
        guard let calls = calls[Self.retryImmediately],
              calls.count > index else {
            return nil
        }

        return calls[index] as? RetryImmediatelyCall
    }
}

// MARK: - Fetch Details for Recommendation
extension MockSource {
    static let fetchDetailsForRecommendation = "fetchDetailsForRecommendation"
    typealias FetchDetailsForRecommendationImpl = (Recommendation) async throws -> Bool

    struct FetchDetailsForRecommendationCall {
        let recommendation: Recommendation
    }

    func stubFetchDetailsForRecommendation(impl: @escaping FetchDetailsForRecommendationImpl) {
        implementations[Self.fetchDetailsForRecommendation] = impl
    }

    func fetchDetails(for recommendation: Recommendation) async throws -> Bool {
        guard let impl = implementations[Self.fetchDetailsForRecommendation] as? FetchDetailsForRecommendationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchDetailsForRecommendation] = (calls[Self.fetchDetailsForRecommendation] ?? []) + [
            FetchDetailsForRecommendationCall(recommendation: recommendation)
        ]

        return try await impl(recommendation)
    }

    func fetchDetailsForRecommendationCall(at index: Int) -> FetchDetailsForRecommendationCall? {
        guard let calls = calls[Self.fetchDetailsForRecommendation],
              calls.count > index else {
            return nil
        }

        return calls[index] as? FetchDetailsForRecommendationCall
    }
}

// MARK: - Fetch item by URL
extension MockSource {
    private static let fetchItem = "fetchItem"
    typealias FetchItemImpl = (String) -> Item?

    struct FetchItemCall {
        let url: String
    }

    func stubFetchItem(impl: @escaping FetchItemImpl) {
        implementations[Self.fetchItem] = impl
    }

    func fetchItem(_ url: String) -> Item? {
        guard let impl = implementations[Self.fetchItem] as? FetchItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchItem] = (calls[Self.fetchItem] ?? []) + [FetchItemCall(url: url)]
        return impl(url)
    }
}

// MARK: - Fetch Items by Search
extension MockSource {
    private static let searchTerm = "searchTerm"
    typealias SearchItemsImpl = (String) -> [SavedItem]?

    struct SearchItemsCall {
        let searchTerm: String
    }

    func stubSearchItems(impl: @escaping SearchItemsImpl) {
        implementations[Self.searchTerm] = impl
    }

    func searchSaves(search: String) -> [Sync.SavedItem]? {
        guard let impl = implementations[Self.searchTerm] as? SearchItemsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.searchTerm] = (calls[Self.searchTerm] ?? []) + [SearchItemsCall(searchTerm: search)]
        return impl(search)
    }

    func searchSavesCall(at index: Int) -> SearchItemsCall? {
        guard let calls = calls[Self.searchTerm],
              calls.count > index else {
            return nil
        }

        return calls[index] as? SearchItemsCall
    }
}

// MARK: - Fetch SavedItem by Remote ID
extension MockSource {
    private static let fetchSavedItem = "fetchSavedItem"
    typealias FetchSavedItemImpl = (String) -> SavedItem?

    struct FetchSavedItemCall {
        let url: String
    }

    func stubFetchSavedItem(impl: @escaping FetchSavedItemImpl) {
        implementations[Self.fetchSavedItem] = impl
    }

    func fetchOrCreateSavedItem(with url: String, and remoteParts: SavedItem.RemoteSavedItem?) -> SavedItem? {
        guard let impl = implementations[Self.fetchSavedItem] as? FetchSavedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchSavedItem] = (calls[Self.fetchSavedItem] ?? []) + [FetchSavedItemCall(url: url)]
        return impl(url)
    }

    func fetchSavedItemCall(at index: Int) -> FetchSavedItemCall? {
        guard let calls = calls[Self.fetchSavedItem],
              calls.count > index else {
            return nil
        }

        return calls[index] as? FetchSavedItemCall
    }
}

// MARK: - Fetch unread saves count
extension MockSource {
    private static let unreadSaves = "unreadSaves"
    typealias UnreadSavesImpl = () -> Int

    struct UnreadSavesCall { }

    func stubUnreadSaves(impl: @escaping UnreadSavesImpl) {
        implementations[Self.unreadSaves] = impl
    }

    func unreadSaves() -> Int {
        guard let impl = implementations[Self.unreadSaves] as? UnreadSavesImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.unreadSaves] = (calls[Self.unreadSaves] ?? []) + [UnreadSavesCall()]
        return impl()
    }

    func fetchUnreadSaves(at index: Int) -> UnreadSavesCall? {
        guard let calls = calls[Self.unreadSaves],
              calls.count > index else {
            return nil
        }

        return calls[index] as? UnreadSavesCall
    }
}

// MARK: - Proxy view refresh to space
extension MockSource {
    private static let viewRefresh = "viewRefresh"
    typealias ViewRefreshImpl = (NSManagedObject, Bool) -> Void

    struct ViewRefreshCall {
        let object: NSManagedObject
        let mergeChanges: Bool
    }

    func stubViewRefresh(impl: @escaping ViewRefreshImpl) {
        implementations[Self.viewRefresh] = impl
    }

    func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool) {
        guard let impl = implementations[Self.viewRefresh] as? ViewRefreshImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.viewRefresh] = (calls[Self.viewRefresh] ?? []) + [ViewRefreshCall(object: object, mergeChanges: flag)]
        return impl(object, flag)
    }

    func fetchViewRefresh(at index: Int) -> ViewRefreshCall? {
        guard let calls = calls[Self.viewRefresh],
              calls.count > index else {
            return nil
        }

        return calls[index] as? ViewRefreshCall
    }
}

// MARK: - refreshTags
extension MockSource {
    private static let refreshTags = "refreshTags"
    typealias RefreshTagsImpl = ((() -> Void)?) -> Void

    struct RefreshTagsCall {
        let completion: (() -> Void)?
    }

    func stubRefreshTags(impl: @escaping RefreshTagsImpl) {
        implementations[Self.refreshTags] = impl
    }

    func refreshTags(completion: (() -> Void)?) {
        guard let impl = implementations[Self.refreshTags] as? RefreshTagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.refreshTags] = (calls[Self.refreshTags] ?? []) + [
            RefreshTagsCall(completion: completion)
        ]

        impl(completion)
    }

    func refreshTagsCall(at index: Int) -> RefreshTagsCall? {
        guard let calls = calls[Self.refreshTags], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshTagsCall
    }
}

// MARK: - fetchUserData
extension MockSource {
    private static let fetchUserData = "fetchUserData"
    typealias FetchUserDataImpl = () -> Void

    struct FetchUserDataCall {
    }

    func stubFetchUserData(impl: @escaping RefreshTagsImpl) {
        implementations[Self.refreshTags] = impl
    }

    func fetchUserData() async throws {
        guard let impl = implementations[Self.fetchUserData] as? FetchUserDataImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchUserData] = (calls[Self.fetchUserData] ?? []) + [
            FetchUserDataCall()
        ]

        impl()
    }

    func fetchUserDataCall(at index: Int) -> RefreshTagsCall? {
        guard let calls = calls[Self.refreshTags], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshTagsCall
    }
}

// MARK: - fetchAllFeatureFlags
extension MockSource {
    private static let fetchAllFeatureFlags = "fetchAllFeatureFlags"
    typealias FetchAllFeatureFlagsImpl = () -> Void

    struct FetchAllFeatureFlagsCall {
    }

    func stubAllFeatureFlags(impl: @escaping FetchAllFeatureFlagsImpl) {
        implementations[Self.fetchAllFeatureFlags] = impl
    }

    func fetchAllFeatureFlags() async throws {
        guard let impl = implementations[Self.fetchAllFeatureFlags] as? FetchAllFeatureFlagsImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchUserData] = (calls[Self.fetchAllFeatureFlags] ?? []) + [
            FetchAllFeatureFlagsCall()
        ]

        impl()
    }

    func fetchAllFeatureFlagsCall(at index: Int) -> FetchAllFeatureFlagsCall? {
        guard let calls = calls[Self.refreshTags], calls.count > index else {
            return nil
        }

        return calls[index] as? FetchAllFeatureFlagsCall
    }
}

// MARK: - fetchAllFeatureFlags
extension MockSource {
    private static let fetchFeatureFlag = "fetchFeatureFlag"
    typealias FetchFeatureFlagImpl = (String) -> Sync.FeatureFlag?

    struct FetchFeatureFlagCall {
        let name: String
    }

    func stubFetchFeatureFlag(impl: @escaping FetchAllFeatureFlagsImpl) {
        implementations[Self.fetchFeatureFlag] = impl
    }

    func fetchFeatureFlag(by name: String) -> Sync.FeatureFlag? {
        guard let impl = implementations[Self.fetchFeatureFlag] as? FetchFeatureFlagImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchFeatureFlag] = (calls[Self.fetchAllFeatureFlags] ?? []) + [
            FetchFeatureFlagCall(name: name)
        ]

        return impl(name)
    }

    func fetchFeatureFlagCall(at index: Int) -> FetchFeatureFlagCall? {
        guard let calls = calls[Self.fetchFeatureFlag], calls.count > index else {
            return nil
        }

        return calls[index] as? FetchFeatureFlagCall
    }
}

 // MARK: fetchCollection
 extension MockSource {
    private static let fetchCollection = "fetchCollection"
    typealias FetchCollectionImpl = (String) async throws -> Void

    struct FetchCollectionCall {
        let slug: String
    }

    func stubFetchCollection(impl: @escaping FetchCollectionImpl) {
        implementations[Self.fetchCollection] = impl
    }

    func fetchCollection(by slug: String) async throws {
        guard let impl = implementations[Self.fetchCollection] as? FetchCollectionImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.fetchCollection] = (calls[Self.fetchCollection] ?? []) + [
            FetchCollectionCall(slug: slug)
        ]

        try await impl(slug)
    }

    func fetchCollectionCall(at index: Int) -> FetchCollectionCall? {
        guard let calls = calls[Self.fetchCollection], calls.count > index else {
            return nil
        }

        return calls[index] as? FetchCollectionCall
    }
 }
