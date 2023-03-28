@testable import Sync

class MockUserService: UserService {
    var implementations: [String: Any] = [:]
    var calls: [String: [Any]] = [:]
}

extension MockUserService {
    static let fetchUser = "fetchUser"
    typealias FetchUserImpl = () async throws -> Void

    struct FetchUser { }

    func fetchUser() async throws {
        guard let impl = implementations[Self.fetchUser] as? FetchUserImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchUser] = (calls[Self.fetchUser] ?? []) + [FetchUser()]

        try await impl()
    }
}
