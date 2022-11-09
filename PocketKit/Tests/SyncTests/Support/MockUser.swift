import SharedPocketKit

class MockUser: User {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - Set Status
extension MockUser {
    private static let setStatus = "setStatus"
    typealias SetStatusImpl = (Bool) -> Void

    struct SetStatusCall {
        let isPremium: Bool
    }

    func stubSetStatus(impl: @escaping SetStatusImpl) {
        implementations[Self.setStatus] = impl
    }

    func setPremiumStatus(_ isPremium: Bool) {
        guard let impl = implementations[Self.setStatus] as? SetStatusImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setStatus] = (calls[Self.setStatus] ?? []) + [
            SetStatusCall(isPremium: isPremium)
        ]

        impl(isPremium)
    }

    func setStatusCall(at index: Int) -> SetStatusCall? {
        guard let calls = calls[Self.setStatus],
              calls.count > index else {
            return nil
        }

        return calls[index] as? SetStatusCall
    }
}

// MARK: - Clear
extension MockUser {
    private static let clear = "clear"
    typealias ClearImpl = () -> Void

    struct ClearCall { }

    func stubClear(impl: @escaping ClearImpl) {
        implementations[Self.clear] = impl
    }

    func clear() {
        guard let impl = implementations[Self.clear] as? ClearImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.clear] = (calls[Self.clear] ?? []) + [
            ClearCall()
        ]

        impl()
    }
}
