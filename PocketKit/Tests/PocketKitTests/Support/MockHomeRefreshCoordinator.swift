@testable import PocketKit

class MockHomeRefreshCoordinator: HomeRefreshCoordinatorProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockHomeRefreshCoordinator {
    private static let refresh = "refresh"
    typealias RefreshImpl = (Bool, () -> Void) -> Void

    struct RefreshCall {
        let isForced: Bool
        let completion: () -> Void
    }

    func stubRefresh(impl: @escaping RefreshImpl) {
        implementations[Self.refresh] = impl
    }

    func refresh(isForced: Bool, _ completion: @escaping () -> Void) {
        guard let impl = implementations[Self.refresh] as? RefreshImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.refresh] = (calls[Self.refresh] ?? []) + [
            RefreshCall(isForced: isForced, completion: completion)
        ]

        impl(isForced, completion)
    }

    func refreshCall(at index: Int) -> RefreshCall? {
        guard let calls = calls[Self.refresh], calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshCall
    }
}
