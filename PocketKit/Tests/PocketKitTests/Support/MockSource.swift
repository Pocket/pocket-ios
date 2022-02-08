import Sync
import Foundation
import CoreData


class MockSource: Source {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var mainContext: NSManagedObjectContext {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func clear() {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func makeItemsController() -> NSFetchedResultsController<SavedItem> {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func object<T>(id: NSManagedObjectID) -> T? where T : NSManagedObject {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func favorite(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func unfavorite(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func delete(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func archive(item: SavedItem) {
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

// MARK: - Fetch Archived items
extension MockSource {
    typealias FetchArchivedItemsImpl = () async throws -> [ArchivedItem]

    func stubFetchArchivedItems(impl: @escaping FetchArchivedItemsImpl) {
        implementations["fetchArchivedItems()"] = impl
    }

    func fetchArchivedItems(isFavorite: Bool) async throws -> [ArchivedItem] {
        guard let impl = implementations["fetchArchivedItems()"] as? FetchArchivedItemsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return try await impl()
    }
}

// MARK: - Delete
extension MockSource {
    typealias DeleteArchivedItemImpl = (ArchivedItem) async throws -> Void

    struct DeleteArchivedItemCall {
        let item: ArchivedItem
    }

    func stubDelete(impl: @escaping DeleteArchivedItemImpl) {
        implementations["deleteArchivedItem"] = impl
    }

    func delete(item: ArchivedItem) async throws {
        guard let impl = implementations["deleteArchivedItem"] as? DeleteArchivedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls["deleteArchivedItem"] = (calls["deleteArchivedItem"] ?? [])
        calls["deleteArchivedItem"]?.append(DeleteArchivedItemCall(item: item))

        try await impl(item)
    }

    func deleteArchivedItemCall(at index: Int) -> DeleteArchivedItemCall? {
        guard let calls = calls["deleteArchivedItem"], calls.count > index else {
            return nil
        }

        return calls[index] as? DeleteArchivedItemCall
    }
}

// MARK: - Favorite archived item
extension MockSource {
    static let favoriteArchivedItem = "favoriteArchivedItem"
    typealias FavoriteArchivedItemImpl = (ArchivedItem) async throws -> Void
    struct FavoriteArchivedItemCall {
        let item: ArchivedItem
    }

    func stubFavoriteArchivedItem(impl: @escaping FavoriteArchivedItemImpl) {
        implementations[Self.favoriteArchivedItem] = impl
    }

    func favorite(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.favoriteArchivedItem] as? FavoriteArchivedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.favoriteArchivedItem] = (calls[Self.favoriteArchivedItem] ?? []) + [
            FavoriteArchivedItemCall(item: item)
        ]

        try await impl(item)
    }

    func favoriteArchivedItemCall(at index: Int) -> FavoriteArchivedItemCall? {
        guard let calls = calls[Self.favoriteArchivedItem], calls.count > index else {
            return nil
        }

        return calls[index] as? FavoriteArchivedItemCall
    }
}

// MARK: - Unfavorite archived item
extension MockSource {
    static let unfavoriteArchivedItem = "unfavoriteArchivedItem"
    typealias UnfavoriteArchivedItemImpl = (ArchivedItem) async throws -> Void
    struct UnfavoriteArchivedItemCall {
        let item: ArchivedItem
    }

    func stubUnfavoriteArchivedItem(impl: @escaping UnfavoriteArchivedItemImpl) {
        implementations[Self.unfavoriteArchivedItem] = impl
    }

    func unfavorite(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.unfavoriteArchivedItem] as? UnfavoriteArchivedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.unfavoriteArchivedItem] = (calls[Self.unfavoriteArchivedItem] ?? []) + [
            UnfavoriteArchivedItemCall(item: item)
        ]

        try await impl(item)
    }

    func unfavoriteArchivedItemCall(at index: Int) -> UnfavoriteArchivedItemCall? {
        guard let calls = calls[Self.unfavoriteArchivedItem], calls.count > index else {
            return nil
        }

        return calls[index] as? UnfavoriteArchivedItemCall
    }
}

// Re-add an archived item
extension MockSource {
    static let reAddArchivedItem = "reAddArchivedItem"
    typealias ReAddArchivedItemImpl = (ArchivedItem) async throws -> Void

    struct ReAddArchivedItemCall {
        let item: ArchivedItem
    }

    func stubReAddArchivedItem(impl: @escaping ReAddArchivedItemImpl) {
        implementations[Self.reAddArchivedItem] = impl
    }

    func reAdd(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.reAddArchivedItem] as? ReAddArchivedItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.reAddArchivedItem] = (calls[Self.reAddArchivedItem] ?? []) + [
            ReAddArchivedItemCall(item: item)
        ]

        try await impl(item)
    }
}
