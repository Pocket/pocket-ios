// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
@testable import PocketKit
import UIKit

class MockPushNotificationProtocol: PushNotificationProtocol {
    internal var implementations: [String: Any] = [:]
    internal var calls: [String: [Any]] = [:]
}

// MARK: Logged in
extension MockPushNotificationProtocol {
    static let loggedIn = "loggedIn"
    typealias LoggedInImpl = (SharedPocketKit.Session) -> Void
    struct LoggedInCall {
        let session: SharedPocketKit.Session
    }

    func stubLoggedIn(impl: @escaping LoggedInImpl) {
        implementations[Self.loggedIn] = impl
    }

    func loggedIn(session: SharedPocketKit.Session) {
        guard let impl = implementations[Self.loggedIn] as? LoggedInImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.loggedIn] = (calls[Self.loggedIn] ?? []) + [LoggedInCall(session: session)]

        return impl(session)
    }

    func loggedInCall(at index: Int) -> LoggedInImpl? {
        guard let calls = calls[Self.loggedIn],
              calls.count > index else {
            return nil
        }

        return calls[index] as? LoggedInImpl
    }

    func loggedInCalls() -> Int {
        guard let calls = calls[Self.loggedIn] else {
            return 0
        }

        return calls.count
    }
}

// MARK: Logged out
extension MockPushNotificationProtocol {
    static let loggedOut = "loggedOut"
    typealias LoggedOutImpl = (SharedPocketKit.Session?) -> Void
    struct LoggedOutCall {
        let session: SharedPocketKit.Session?
    }

    func stubLoggedOut(impl: @escaping LoggedOutImpl) {
        implementations[Self.loggedOut] = impl
    }

    func loggedOut(session: SharedPocketKit.Session?) {
        guard let impl = implementations[Self.loggedOut] as? LoggedOutImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.loggedOut] = (calls[Self.loggedOut] ?? []) + [LoggedOutCall(session: session)]

        return impl(session)
    }

    func loggedOutCall(at index: Int) -> LoggedOutImpl? {
        guard let calls = calls[Self.loggedOut],
              calls.count > index else {
            return nil
        }

        return calls[index] as? LoggedOutImpl
    }

    func loggedOutCalls() -> Int {
        guard let calls = calls[Self.loggedOut] else {
            return 0
        }

        return calls.count
    }
}

// MARK: Register Device Token
extension MockPushNotificationProtocol {
    static let register = "register"
    typealias RegisterImpl = (Data) -> Void
    struct RegisterCall {
        let deviceToken: Data
    }

    func stubRegister(impl: @escaping RegisterImpl) {
        implementations[Self.register] = impl
    }

    func register(deviceToken: Data) {
        guard let impl = implementations[Self.register] as? RegisterImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.register] = (calls[Self.register] ?? []) + [RegisterCall(deviceToken: deviceToken)]

        return impl(deviceToken)
    }

    func registerCall(at index: Int) -> RegisterImpl? {
        guard let calls = calls[Self.register],
              calls.count > index else {
            return nil
        }

        return calls[index] as? RegisterImpl
    }
}

// MARK: HandleBackground Notification
extension MockPushNotificationProtocol {
    static let handleBackgroundNotifcation = "handleBackgroundNotifcation"
    typealias HandleBackgroundNotifcationImpl = ([AnyHashable: Any], ((UIBackgroundFetchResult) -> Void)) -> Bool
    struct HandleBackgroundNotifcationCall {
        let userInfo: [AnyHashable: Any]
        let completionHandler: (UIBackgroundFetchResult) -> Void
    }

    func stubHandleBackgroundNotifcation(impl: @escaping HandleBackgroundNotifcationImpl) {
        implementations[Self.handleBackgroundNotifcation] = impl
    }

    func handleBackgroundNotifcation(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        guard let impl = implementations[Self.handleBackgroundNotifcation] as? HandleBackgroundNotifcationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.handleBackgroundNotifcation] = (calls[Self.handleBackgroundNotifcation] ?? []) + [HandleBackgroundNotifcationCall(userInfo: userInfo, completionHandler: completionHandler)]

        return impl(userInfo, completionHandler)
    }

    func handleBackgroundNotifcationCall(at index: Int) -> HandleBackgroundNotifcationImpl? {
        guard let calls = calls[Self.handleBackgroundNotifcation],
              calls.count > index else {
            return nil
        }

        return calls[index] as? HandleBackgroundNotifcationImpl
    }
}
