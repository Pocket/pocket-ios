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
