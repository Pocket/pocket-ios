@testable import Sync


class MockSlateService: SlateService {
    typealias FetchSlateLineupImpl = () async throws -> SlateLineup
    private var fetchSlateLineupImpl: FetchSlateLineupImpl?
    func stubFetchSlateLineup(impl: @escaping FetchSlateLineupImpl) {
        fetchSlateLineupImpl = impl
    }

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        guard let impl = fetchSlateLineupImpl else {
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
