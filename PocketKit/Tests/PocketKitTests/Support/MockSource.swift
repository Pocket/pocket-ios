import Sync
import Foundation
import CoreData
import Combine


class MockSource: Source {
    var _events: SyncEvents = SyncEvents()
    var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var mainContext: NSManagedObjectContext {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func clear() {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func fetchSlate(_ slateID: String) async throws -> Slate? {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func savedRecommendationsService() -> SavedRecommendationsService {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func save(recommendation: Slate.Recommendation) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func archive(recommendation: Slate.Recommendation) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func restore() {
        fatalError("\(Self.self).\(#function) is not implemented")
    }
}

extension MockSource {
    private static let object = "object"
    typealias ObjectImpl<T> = (NSManagedObjectID) -> T

    func stubObject<T: NSManagedObject>(_ impl: @escaping ObjectImpl<T>) {
        implementations[Self.object] = impl
    }

    func object<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        guard let impl = implementations[Self.object] as? ObjectImpl<T> else {
            fatalError("\(Self.self)#\(#function) is not implemented")
        }

        return impl(id)
    }
}

// MARK: - Refresh
extension MockSource {
    private static let refresh = "refresh"
    typealias RefreshImpl = (Int, (() -> Void)?) -> Void

    struct RefreshCall {
        let maxItems: Int
        let completion: (() -> Void)?
    }

    func stubRefresh(impl: @escaping RefreshImpl) {
        implementations[Self.refresh] = impl
    }

    func refresh(maxItems: Int, completion: (() -> ())?) {
        guard let impl = implementations[Self.refresh] as? RefreshImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.refresh] = (calls[Self.refresh] ?? []) + [
            RefreshCall(maxItems: maxItems, completion: completion)
        ]

        impl(maxItems, completion)
    }

    func refreshCall(at index: Int) -> RefreshCall? {
        guard let calls = calls[Self.refresh], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshCall
    }
}

// MARK: - Make items controller
extension MockSource {
    static let makeItemsController = "makeItemsController"
    typealias MakeItemsControllerImpl = () -> SavedItemsController

    struct MakeItemsControllerCall { }

    func stubMakeItemsController(impl: @escaping MakeItemsControllerImpl) {
        implementations[Self.makeItemsController] = impl
    }

    func makeItemsController() -> SavedItemsController {
        guard let impl = implementations[Self.makeItemsController] as? MakeItemsControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeItemsController] = (calls[Self.makeItemsController] ?? []) + [MakeItemsControllerCall()]

        return impl()
    }
}

// MARK: - Make archived items controller
extension MockSource {
    static let makeArchivedItemsController = "makeArchivedItemsController"
    typealias MakeArchivedItemsControllerImpl = () -> SavedItemsController

    struct MakeArchivedItemsControllerCall { }

    func stubMakeArchivedItemsController(impl: @escaping MakeArchivedItemsControllerImpl) {
        implementations[Self.makeArchivedItemsController] = impl
    }

    func makeArchivedItemsController() -> SavedItemsController {
        guard let impl = implementations[Self.makeArchivedItemsController] as? MakeArchivedItemsControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeArchivedItemsController] = (calls[Self.makeArchivedItemsController] ?? []) + [MakeArchivedItemsControllerCall()]

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

// MARK: - Refresh an object
extension MockSource {
    static let refreshObject = "refreshObject"
    typealias RefreshObjectImpl = (NSManagedObject, Bool) -> Void
    struct RefreshObjectCall {
        let object: NSManagedObject
        let mergeChanges: Bool
    }

    func stubRefreshObject(impl: @escaping RefreshObjectImpl) {
        implementations[Self.refreshObject] = impl
    }

    func refresh(_ object: NSManagedObject, mergeChanges: Bool) {
        guard let impl = implementations[Self.refreshObject] as? RefreshObjectImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.refreshObject] = (calls[Self.refreshObject] ?? []) + [
            RefreshObjectCall(object: object, mergeChanges: mergeChanges)
        ]

        impl(object, mergeChanges)
    }

    func refreshObjectCall(at index: Int) -> RefreshObjectCall? {
        guard let calls = calls[Self.refreshObject], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshObjectCall
    }
}
