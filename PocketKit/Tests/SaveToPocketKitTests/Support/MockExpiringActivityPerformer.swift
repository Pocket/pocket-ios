@testable import SaveToPocketKit


class MockExpiringActivityPerformer: ExpiringActivityPerformer {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockExpiringActivityPerformer {
    static let performImpl = "performImpl"
    typealias PerformImpl = (String, (Bool) -> Void) -> Void

    struct PerformCall {
        let reason: String
    }

    func stubPerformExpiringActivity(_ impl: @escaping PerformImpl) {
        implementations[Self.performImpl] = impl
    }

    func performCall(at index: Int) -> PerformCall? {
        calls[Self.performImpl]?[index] as? PerformCall
    }

    func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void) {
        guard let impl = implementations[Self.performImpl] as? PerformImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.performImpl] = (calls[Self.performImpl] ?? []) + [PerformCall(reason: reason)]
        impl(reason, block)
    }
}
