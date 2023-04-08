@testable import Sync

class MockFeatureFlagService: FeatureFlagLoadingService {
    var implementations: [String: Any] = [:]
    var calls: [String: [Any]] = [:]
}

extension MockFeatureFlagService {
    static let fetchFeatureFlags = "fetchFeatureFlags"
    typealias FetchFeatureFlagsImpl = () async throws -> Void

    struct FetchFeatureFlagsCall {
    }

    func stubFetchFeatureFlags(impl: @escaping FetchFeatureFlagsImpl) {
        implementations[Self.fetchFeatureFlags] = impl
    }

    func fetchFeatureFlags() async throws {
        guard let impl = implementations[Self.fetchFeatureFlags] as? FetchFeatureFlagsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.fetchFeatureFlags] = (calls[Self.fetchFeatureFlags] ?? []) + [
            FetchFeatureFlagsCall()
        ]

        try await impl()
    }

    func fetchFeatureFlagsCall(at index: Int) -> FetchFeatureFlagsCall? {
        guard let calls = calls[Self.fetchFeatureFlags],
              calls.count > index,
              let call = calls[index] as? FetchFeatureFlagsCall else {
                  return nil
              }

        return call
    }
}
