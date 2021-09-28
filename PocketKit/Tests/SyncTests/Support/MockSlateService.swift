@testable import Sync


class MockSlateService: SlateService {
    typealias FetchSlatesImpl = () async throws -> [Slate]
    private var fetchSlatesImpl: FetchSlatesImpl?
    func stubFetchSlates(impl: @escaping FetchSlatesImpl) {
        fetchSlatesImpl = impl
    }

    func fetchSlates() async throws -> [Slate] {
        guard let impl = fetchSlatesImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return try await impl()
    }

    typealias FetchSlateImpl = (String) async throws -> Slate?
    private var fetchSlateImpl: FetchSlateImpl?
    func stubFetchSlate(impl: @escaping FetchSlateImpl) {
        fetchSlateImpl = impl
    }

    func fetchSlate(_ slateID: String) async throws -> Slate? {
        guard let impl = fetchSlateImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return try await impl(slateID)
    }
}
