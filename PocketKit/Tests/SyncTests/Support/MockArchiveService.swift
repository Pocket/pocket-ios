@testable import Sync


class MockArchiveService: ArchiveService {
    private var implementations: [String: Any] = [:]

    typealias FetchImpl = () async throws -> [ArchivedItem]
    func stubFetch(impl: @escaping FetchImpl) {
        implementations["fetch"] = impl
    }

    func fetch(accessToken: String?) async throws -> [ArchivedItem] {
        guard let impl = implementations["fetch"] as? FetchImpl else {
            fatalError("\(Self.self)#\(#function) is not stubbed")
        }

        return try await impl()
    }
    
}
