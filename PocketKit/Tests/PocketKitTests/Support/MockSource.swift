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

    func fetchSlate(_ slateID: String) async throws {
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

// MARK: - Make slate lineup controller
extension MockSource {
    static let makeSlateLineupController = "makeSlateLineupController"
    typealias MakeSlateLineupControllerImpl = () -> SlateLineupController

    struct MakeSlateLineupControllerCall { }

    func stubMakeSlateLineupController(impl: @escaping MakeSlateLineupControllerImpl) {
        implementations[Self.makeSlateLineupController] = impl
    }

    func makeSlateLineupController() -> SlateLineupController {
        guard let impl = implementations[Self.makeSlateLineupController] as? MakeSlateLineupControllerImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.makeSlateLineupController] = (calls[Self.makeSlateLineupController] ?? []) + [MakeSlateLineupControllerCall()]

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

// MARK: - Resolved unresolved saved items
extension MockSource {
    static let resolveUnresolvedSavedItems = "resolveUnresolvedSavedItems"
    typealias ResolveUnresolvedSavedItemsImpl = () -> Void
    struct ResolveUnresolvedSavedItemsCall { }

    func stubResolveUnresolvedSavedItems(impl: @escaping ResolveUnresolvedSavedItemsImpl) {
        implementations[Self.resolveUnresolvedSavedItems] = impl
    }

    func resolveUnresolvedSavedItems() {
        guard let impl = implementations[Self.resolveUnresolvedSavedItems] as? ResolveUnresolvedSavedItemsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.resolveUnresolvedSavedItems] = (calls[Self.resolveUnresolvedSavedItems] ?? []) + [
            ResolveUnresolvedSavedItemsCall()
        ]

        impl()
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

    func fetchSlateLineup(_ identifier: String) async throws {
        guard let impl = implementations[Self.fetchSlateLineup] as? FetchSlateLineupImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchSlateLineup] = (calls[Self.fetchSlateLineup] ?? []) + [
            FetchSlateLineupCall(identifier: identifier)
        ]

        impl(identifier)
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
}
