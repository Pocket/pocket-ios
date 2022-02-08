@testable import Sync


class MockArchiveService: ArchiveService {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - Fetch
extension MockArchiveService {
    typealias FetchImpl = () async throws -> [ArchivedItem]
    func stubFetch(impl: @escaping FetchImpl) {
        implementations["fetch"] = impl
    }

    func fetch(accessToken: String?, isFavorite: Bool) async throws -> [ArchivedItem] {
        guard let impl = implementations["fetch"] as? FetchImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        return try await impl()
    }
}

// MARK: - Delete
extension MockArchiveService {
    typealias DeleteImpl = (ArchivedItem) async throws -> ()

    struct DeleteCall {
        let item: ArchivedItem
    }

    func stubDelete(impl: @escaping DeleteImpl) {
        implementations["delete"] = impl
    }

    func delete(item: ArchivedItem) async throws {
        guard let impl = implementations["delete"] as? DeleteImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        calls["delete"] = (calls["delete"] ?? []) + [DeleteCall(item: item)]
        return try await impl(item)
    }

    func deleteCall(at index: Int) -> DeleteCall? {
        calls["delete"]?[index] as? DeleteCall
    }
}

// MARK: - Favorite
extension MockArchiveService {
    static let favorite = "favorite"

    typealias FavoriteImpl = (ArchivedItem) async throws -> ()

    struct FavoriteCall {
        let item: ArchivedItem
    }

    func stubFavorite(impl: @escaping FavoriteImpl) {
        implementations[Self.favorite] = impl
    }

    func favorite(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.favorite] as? FavoriteImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        calls[Self.favorite] = (calls[Self.favorite] ?? []) + [FavoriteCall(item: item)]
        return try await impl(item)
    }

    func favoriteCall(at index: Int) -> FavoriteCall? {
        calls[Self.favorite]?[index] as? FavoriteCall
    }
}

// MARK: - Favorite
extension MockArchiveService {
    static let unfavorite = "unfavorite"

    typealias UnfavoriteImpl = (ArchivedItem) async throws -> ()

    struct UnfavoriteCall {
        let item: ArchivedItem
    }

    func stubUnfavorite(impl: @escaping UnfavoriteImpl) {
        implementations[Self.unfavorite] = impl
    }

    func unfavorite(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.unfavorite] as? UnfavoriteImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        calls[Self.unfavorite] = (calls[Self.unfavorite] ?? []) + [UnfavoriteCall(item: item)]
        try await impl(item)
    }

    func unfavoriteCall(at index: Int) -> UnfavoriteCall? {
        calls[Self.unfavorite]?[index] as? UnfavoriteCall
    }
}

// MARK: - Re-add
extension MockArchiveService {
    static let reAdd = "re-add"
    typealias ReAddImpl = (ArchivedItem) async throws -> ()
    struct ReAddCall {
        let item: ArchivedItem
    }

    func stubReAdd(impl: @escaping ReAddImpl) {
        implementations[Self.reAdd] = impl
    }

    func reAdd(item: ArchivedItem) async throws {
        guard let impl = implementations[Self.reAdd] as? ReAddImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        calls[Self.reAdd] = (calls[Self.reAdd] ?? []) + [ReAddCall(item: item)]
        try await impl(item)
    }

    func reAddCall(at index: Int) -> ReAddCall? {
        calls[Self.reAdd].flatMap {
            guard $0.count > index else {
                return nil
            }

            return $0[index] as? ReAddCall
        }
    }
}
