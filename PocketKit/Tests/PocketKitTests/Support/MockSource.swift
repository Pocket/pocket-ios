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

    func refresh(maxItems: Int, completion: (() -> ())?) {
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
        calls["deleteArchivedItem"]?[index] as? DeleteArchivedItemCall
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
        calls[Self.favoriteArchivedItem]?[index] as? FavoriteArchivedItemCall
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
        calls[Self.unfavoriteArchivedItem]?[index] as? UnfavoriteArchivedItemCall
    }
}
