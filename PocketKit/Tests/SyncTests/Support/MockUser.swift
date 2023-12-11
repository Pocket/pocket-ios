// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import Combine

class MockUser: User {
    @Published public private(set) var status: Status
    public var statusPublisher: Published<Status>.Publisher { $status }
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
    var userName: String = ""
    var displayName: String = ""
    var email: String = ""

    init(status: Status = .unknown) {
        self.status = status
    }
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
    typealias SetParameterImpl = (String) -> Void
    private static let setUserName = "setUserName"
    private static let setDisplayName = "setDisplayName"
    private static let setEmail = "setEmail"

    struct SetUserName {
        let userName: String
    }

    struct SetDisplayName {
        let displayName: String
    }

    struct SetEmail {
        let email: String
    }

    func stubSetUserName(impl: @escaping SetParameterImpl) {
        implementations[Self.setUserName] = impl
    }

    func stubSetDisplayName(impl: @escaping SetParameterImpl) {
        implementations[Self.setDisplayName] = impl
    }

    func stubSetEmail(impl: @escaping SetParameterImpl) {
        implementations[Self.setEmail] = impl
    }

    func stubStandardUserName() {
        implementations[Self.setUserName] = { userName in self.userName = userName ? "Set User" : "Unset User" }
    }

    func stubStandardDisplayName() {
        implementations[Self.setDisplayName] = { displayName in self.displayName = displayName ? "Set Display" : "Unset Display" }
    }

    func setUserName(_ userName: String) {
        guard let impl = implementations[Self.setUserName] as? SetParameterImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setUserName] = (calls[Self.setUserName] ?? [] + [SetUserName(userName: userName)])

        impl(userName)
    }

    func setDisplayName(_ displayName: String) {
        guard let impl = implementations[Self.setDisplayName] as? SetParameterImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setDisplayName] = (calls[Self.setDisplayName] ?? [] + [SetDisplayName(displayName: displayName)])

        impl(displayName)
    }

    func setEmail(_ email: String) {
        guard let impl = implementations[Self.setEmail] as? SetParameterImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.setEmail] = (calls[Self.setEmail] ?? [] + [SetEmail(email: email)])

        impl(email)
    }
}
