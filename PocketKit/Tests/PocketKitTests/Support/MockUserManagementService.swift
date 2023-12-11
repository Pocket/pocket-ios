// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import PocketKit

class MockUserManagementService: UserManagementServiceProtocol {
    @Published public private(set) var accountDeleted: Bool
    public var accountDeletedPublisher: Published<Bool>.Publisher { $accountDeleted }

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    init(accountDeleted: Bool = false) {
        self.accountDeleted = accountDeleted
    }
}

// MARK: Delete Account
extension MockUserManagementService {
    private static let deleteAccount = "deleteAccount"
    typealias DeleteAccountImpl = () -> Void

    struct DeleteAccountCall { }

    func stubDeleteAccount(impl: @escaping DeleteAccountImpl) {
        implementations[Self.deleteAccount] = impl
    }

    func deleteAccount() async throws {
        guard let impl = implementations[Self.deleteAccount] as? DeleteAccountImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.deleteAccount] = (calls[Self.deleteAccount] ?? []) + [
            DeleteAccountCall()
        ]

        impl()
    }
}

// MARK: Logout
extension MockUserManagementService {
    private static let logout = "logout"
    typealias LogoutImpl = () -> Void

    struct LogoutCall { }

    func stubLogout(impl: @escaping LogoutImpl) {
        implementations[Self.logout] = impl
    }

    func logout() {
        guard let impl = implementations[Self.logout] as? LogoutImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.logout] = (calls[Self.logout] ?? []) + [
            LogoutCall()
        ]

        impl()
    }
}
