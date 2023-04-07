import SharedPocketKit
import Combine

class MockUser: User {
    @Published public private(set) var status: Status = .unknown
    public var statusPublisher: Published<Status>.Publisher { $status }
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
    internal var userName: String = ""
    internal var displayName: String = ""
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

    func stubStandardSetStatus() {
        implementations[Self.setStatus] = { isPremium in
            self.status = isPremium ? .premium : .free
        }
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

// MARK: - User Name
extension MockUser {
    private static let setUserName = "setUserName"
    typealias SetUserNameImpl = (String) -> Void

    private static let setDisplayName = "setDisplayName"
    typealias SetDisplayNameImpl = (String) -> Void

    struct SetUserName {
        let userName: String
    }

    struct SetDisplayName {
        let displayName: String
    }

    func stubSetUserName(impl: @escaping SetUserNameImpl) {
        implementations[Self.setUserName] = impl
    }

    func stubSetDisplayName(impl: @escaping SetDisplayNameImpl) {
        implementations[Self.setDisplayName] = impl
    }

    func stubStandardUserName() {
        implementations[Self.setUserName] = { userName in self.userName = userName ? "Set User" : "Unset User" }
    }

    func stubStandardDisplayName() {
        implementations[Self.setDisplayName] = { displayName in self.displayName = displayName ? "Set Display" : "Unset Display" }
    }

    func setUserName(_ userName: String) {
        guard let impl = implementations[Self.setUserName] as? SetUserNameImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setUserName] = (calls[Self.setUserName] ?? [] + [SetUserName(userName: userName)])

        impl(userName)
    }

    func setDisplayName(_ displayName: String) {
        guard let impl = implementations[Self.setDisplayName] as? SetDisplayNameImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setDisplayName] = (calls[Self.setDisplayName] ?? [] + [SetDisplayName(displayName: displayName)])

        impl(displayName)
    }
}
